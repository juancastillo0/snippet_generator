import 'dart:convert';

import 'package:dart_style/dart_style.dart';
import 'package:file_system_access/src/models/result.dart' as fs;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mobx/mobx.dart';
import 'package:petitparser/petitparser.dart';
import 'package:snippet_generator/gen_parsers/models/predifined_parsers.dart';
import 'package:snippet_generator/gen_parsers/models/store_value.dart';
import 'package:snippet_generator/gen_parsers/models/token_value.dart';
import 'package:snippet_generator/gen_parsers/models/tokens.dart';
import 'package:snippet_generator/globals/pod_notifier.dart';
import 'package:snippet_generator/notifiers/app_notifier.dart';
import 'package:snippet_generator/notifiers/collection_notifier/list_notifier.dart';
import 'package:snippet_generator/notifiers/collection_notifier/map_notifier.dart';
import 'package:snippet_generator/types/root_store.dart';
import 'package:snippet_generator/types/type_models.dart';
import 'package:snippet_generator/utils/extensions.dart';
import 'package:snippet_generator/utils/persistence.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

final testPod = Pod.notifier(1);

final parserStoreProvider = Provider<GenerateParserStore>(
  (ref) => GenerateParserStore(),
);

GenerateParserStore useParserStore() {
  return useRootStore().parserStore;
}

class GenerateParserStore {
  late final persistence = GenerateParserStorePersistence(this);

  final _formatter = DartFormatter();

  final tokenKeys = ListNotifier<String>([]);
  final tokens = MapNotifier<String, ParserTokenNotifier>();

  final selectedTestTokenKey = AppNotifier('');

  late final selectedTestToken =
      Computed(() => tokens[selectedTestTokenKey.value]!);

  final parserTestText = TextNotifier();

  GenerateParserStoreValue makeValue() {
    final _tokens = tokens.values.map((t) => MapEntry(t.key, t.value)).toList();
    return GenerateParserStoreValue(_tokens);
  }

  void addValue(GenerateParserStoreValue value) {
    runInAction(() {
      final incoming = Map.fromEntries(value.tokens.map((e) {
        final value = ParserTokenNotifier(this, e.key);
        value.notifier.value = e.value;
        return MapEntry(e.key, value);
      }));
      final additionalKeys = incoming.keys.where(
        (key) => !tokens.containsKey(key),
      );

      tokenKeys.addAll(additionalKeys);
      tokens.addAll(incoming);
    });
  }

  void add() => runInAction(() {
        final token = ParserTokenNotifier(this, uuid.v4());
        tokens[token.key] = token;
        tokenKeys.add(token.key);
      });

  void remove(String key) => runInAction(() {
        tokens.remove(key);
        tokenKeys.remove(key);
        if (tokens.isEmpty) {
          add();
        }
        if (key == selectedTestTokenKey.value) {
          selectedTestTokenKey.value = tokenKeys.first;
        }
      });

  String generateCode() {
    final Set<PredifinedParser> predifined = {};

    void _processToken(ParserToken token) {
      token.value.map(
        and: (list) => list.values.forEach(_processToken),
        or: (list) => list.values.forEach(_processToken),
        string: (_) {},
        ref: (_) {},
        predifined: (value) {
          predifined.add(value.value);
        },
        separated: (_) {},
      );
    }

    for (final v in tokens.values) {
      _processToken(v.value);
    }
    String code = """
import 'dart:convert';
import 'dart:ui';
import 'package:petitparser/petitparser.dart';

${predifined.map((e) => e.dartDefinition()).whereType<String>().join('\n')}

${tokens.values.map((e) {
      final t = e.value;
      final expressionContext = e.expression.value;
      return 'final ${t.name} = ${expressionContext.expression};\n'
          '\n$expressionContext';
    }).join('\n\n')}

""";

    try {
      code = _formatter.format(code);
    } catch (_) {}
    return code;
  }

  late final parserTestResult = Computed(
    () {
      final parser = selectedTestToken.value.parser.value;
      return parser.when(
        ok: (parser) => parser.parse(parserTestText.value).toString(),
        err: (err) => err.toString(),
      );
    },
  );
}

class GenerateParserStorePersistence {
  final GenerateParserStore store;
  const GenerateParserStorePersistence(this.store);

  Future<void> saveHive() async {
    final parserBox = getBox<GenerateParserStoreValue>();
    await parserBox.clear();

    final value = store.makeValue();
    final _str = jsonEncode(value.toJson());
    await parserBox.add(value);
  }

  Future<void> loadHive() async {
    final parserBox = getBox<GenerateParserStoreValue>();
    final values = parserBox.values;
    if (values.isNotEmpty) {
      store.addValue(values.first);
    }
    if (store.tokenKeys.isEmpty) {
      store.add();
    }
    store.selectedTestTokenKey.value = store.tokenKeys.first;
  }
}

class TokenContext {
  final List<TypeConfig> types = [];
  String expression = '';
  bool withinFlatten = false;
  String _lastName = '';

  String getName(String newName) {
    if (newName.isEmpty) {
      return _lastName;
    } else {
      _lastName = newName;
      return newName;
    }
  }

  TokenContext();

  void add(TypeConfig value) {
    if (withinFlatten) {
      return;
    }
    types.add(value);
  }

  @override
  String toString() {
    return types
        .map((e) => e.sourceCode.value)
        .join('\n')
        .replaceAll("import 'dart:ui';", '')
        .replaceAll("import 'dart:convert';", '');
  }
}

class ParserTokenNotifier {
  final String key;
  final GenerateParserStore store;
  ParserTokenNotifier(this.store, this.key);

  final notifier = AppNotifier(
    const ParserToken.def(
      value: TokenValue.and([ParserToken.def()], flatten: false),
    ),
  );

  ParserToken get value => notifier.value;

  late final parser = Computed<fs.Result<Parser, Object>>(() {
    try {
      return fs.Ok(_parser(value));
    } catch (e) {
      return fs.Err(e);
    }
  });

  Parser _parser(ParserToken token) {
    Parser result = token.value.when(
      and: (list, flatten) {
        Parser p = SequenceParser(list.map((e) => _parser(e)));
        if (flatten) {
          p = p.flatten();
        }
        return p;
      },
      or: (list) => ChoiceParser(list.map((e) => _parser(e))),
      string: (s, isPattern, caseSensitive) {
        if (caseSensitive) {
          return isPattern ? pattern(s) : string(s);
        } else {
          return isPattern ? patternIgnoreCase(s) : stringIgnoreCase(s);
        }
      },
      ref: (ref) => store.tokens[ref]?.parser.value.unwrap() ?? any(),
      predifined: (pred) => pred.parser(),
      separated: (item, separator, includeSeparators, separatorAtEnd) =>
          _parser(item).separatedBy(
        _parser(separator),
        includeSeparators: includeSeparators,
        optionalSeparatorAtEnd: separatorAtEnd,
      ),
    );

    if (token.negated) {
      result = result.neg();
    }
    if (token.trim) {
      result = result.trim();
    }
    return token.repeat.apply(result);
  }

  late final expression = Computed(() {
    final context = TokenContext();
    final expression = _expr(
      context,
      value,
      parent: null,
    );
    context.expression = expression;
    return context;
  });

  String _expr(
    TokenContext context,
    ParserToken token, {
    required ParserToken? parent,
  }) {
    final _inner = token.value.when(
        and: (list, flatten) {
          if (!flatten) {
            final type = TypeConfig(
              isDataValue: true,
              isSerializable: true,
            );
            type.addVariant();
            final _class = type.classes.first;
            _class.typeConfig = type;
            type.signatureNotifier.value = token.name.toClassName();

            if (list.length == 1) {
            } else {
              for (final innerToken in list) {
                if (innerToken.name.isEmpty) {
                  continue;
                }
                final prop = _class.addProperty();
                prop.classConfig = _class;
                prop.nameNotifier.value = innerToken.name;

                final _type = innerToken.dartType(store.tokens, parent: token);

                final _optional = innerToken.repeat.min == 0;
                prop.isRequiredNotifier.value = !_optional;
                prop.typeNotifier.value = innerToken.repeat.canBeMany
                    ? 'List<$_type>${_optional ? "?" : ""}'
                    : '$_type${_optional ? "?" : ""}';
              }
              context.add(type);
            }
          }
          final _prev = context.withinFlatten;
          context.withinFlatten = _prev || flatten;
          final code = '(' +
              list.map((e) => _expr(context, e, parent: token)).join(' & ') +
              ')${flatten ? ".flatten()" : ""}';
          if (!_prev && flatten) {
            context.withinFlatten = false;
          }
          return code;
        },
        or: (list) {
          final allStrings = list.every(
            (element) => element.value.maybeMap(
              and: (and) => and.flatten,
              string: (string) => !string.isPattern,
              orElse: () => false,
            ),
          );
          if (allStrings) {
            final type = TypeConfig(
              isSerializable: true,
              isEnum: true,
            );
            type.signatureNotifier.value =
                (parent?.name.toClassName() ?? '') + token.name.toClassName();

            int _index = 0;
            for (final innerToken in list) {
              type.addVariant();
              final _class = type.classes[_index++];
              _class.typeConfig = type;
              _class.nameNotifier.value = innerToken.value.maybeMap(
                and: (and) => innerToken.name,
                string: (string) => string.value,
                orElse: () => throw Error(),
              );
              if (_class.name.toUpperCase() == _class.name) {
                _class.nameNotifier.value = _class.name.toLowerCase();
              }
            }

            context.add(type);
          } else {
            final type = TypeConfig(
              isSerializable: true,
              isDataValue: true,
              isSumType: true,
            );
            type.sumTypeConfig.prefix.value = parent?.name.toClassName() ?? '';
            type.signatureNotifier.value = token.dartType(
              store.tokens,
              parent: parent,
            );

            int _index = 0;
            for (final innerToken in list) {
              type.addVariant();
              final _class = type.classes[_index++];
              _class.typeConfig = type;

              final nameAndType = innerToken.value.map(
                and: (and) => and.flatten
                    ? [
                        innerToken.name,
                      ]
                    : [innerToken.name, innerToken.name.toClassName()],
                or: (or) => [innerToken.name, innerToken.name.toClassName()],
                string: (string) => [
                  string.isPattern ? innerToken.name : string.value,
                  'String'
                ],
                predifined: (predifined) =>
                    [innerToken.name, predifined.value.toDartType()],
                ref: (ref) {
                  final _refToken = store.tokens[ref.value];
                  return [
                    innerToken.name.isEmpty
                        ? _refToken?.value.name ?? ''
                        : innerToken.name,
                    _refToken?.value.dartType(store.tokens, parent: token) ?? ''
                  ];
                },
                separated: (separated) => [
                  innerToken.name.isEmpty
                      ? separated.item.name
                      : innerToken.name,
                  'List<${separated.item.dartType(
                    store.tokens,
                    parent: token,
                  )}>'
                ],
              );

              _class.nameNotifier.value = nameAndType.first.toClassName();

              final prop = _class.addProperty();
              prop.classConfig = _class;
              prop.nameNotifier.value = 'value';

              final _type = nameAndType.last;
              prop.typeNotifier.value = innerToken.repeat.canBeMany
                  ? 'List<$_type>'
                  : '$_type${innerToken.repeat.isOptionalSingle ? "?" : ""}';
            }

            context.add(type);
          }
          return '(' +
              list.map((e) => _expr(context, e, parent: token)).join(' | ') +
              ')';
        },
        string: (string, isPattern, caseSensitive) {
          final _c = string.contains("'") ? '"' : "'";
          if (caseSensitive) {
            return isPattern
                ? 'pattern($_c$string$_c)'
                : string.length == 1
                    ? 'char($_c$string$_c)'
                    : 'string($_c$string$_c)';
          } else {
            return isPattern
                ? 'patternIgnoreCase($_c$string$_c)'
                : 'stringIgnoreCase($_c$string$_c)';
          }
        },
        ref: (ref) => store.tokens[ref]?.value.name ?? '',
        predifined: (pred) => pred.toDart(),
        separated: (item, separator, includeSeparators, separatorAtEnd) =>
            '${_expr(context, item, parent: token)}.separatedBy(${_expr(
              context,
              separator,
              parent: token,
            )}, '
            'includeSeparators: $includeSeparators, '
            'optionalSeparatorAtEnd: $separatorAtEnd)');

    return '$_inner${token.negated ? ".neg()" : ""}'
        '${token.trim ? ".trim()" : ""}${token.repeat.toDart()}';
  }

  void setName(String name) {
    notifier.value = notifier.value.copyWith(name: name);
  }

  void setTokenValue(TokenValue value) {
    notifier.value = notifier.value.copyWith(value: value);
  }

  void setRepeat(RepeatRange repeat) {
    notifier.value = notifier.value.copyWith(repeat: repeat);
  }
}

extension ClassNameString on String {
  String toClassName() {
    String _value = this;
    if (_value.toUpperCase() == _value) {
      _value = _value.toLowerCase();
    }
    return _value.snakeToCamel(firstUpperCase: true);
  }
}
