import 'package:file_system_access/src/models/result.dart' as fs;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mobx/mobx.dart';
import 'package:petitparser/petitparser.dart';
import 'package:snippet_generator/gen_parsers/models/predifined_parsers.dart';
import 'package:snippet_generator/gen_parsers/models/token_value.dart';
import 'package:snippet_generator/gen_parsers/models/tokens.dart';
import 'package:snippet_generator/globals/pod_notifier.dart';
import 'package:snippet_generator/notifiers/app_notifier.dart';
import 'package:snippet_generator/notifiers/collection_notifier/list_notifier.dart';
import 'package:snippet_generator/notifiers/collection_notifier/map_notifier.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

final testPod = Pod.notifier(1);

final parserStoreProvider = Provider<GenerateParserStore>(
  (ref) => GenerateParserStore(ref.read),
);

class GenerateParserStore {
  final Reader read;

  GenerateParserStore(this.read) {
    add();
    selectedTestTokenKey.value = tokenKeys.first;
  }

  final tokenKeys = ListNotifier<String>([]);
  final tokens = MapNotifier<String, ParserTokenNotifier>();

  final selectedTestTokenKey = AppNotifier('');

  late final selectedTestToken =
      Computed(() => tokens[selectedTestTokenKey.value]!);

  final parserTestText = TextNotifier();

  void add() => runInAction(() {
        final token = ParserTokenNotifier(this);
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
      );
    }

    for (final v in tokens.values) {
      _processToken(v.value);
    }
    return """

${predifined.map((e) => e.dartDefinition()).whereType<String>().join('\n')}

${tokens.values.map((e) {
      final t = e.value;
      return "final ${t.name} = ${e.expression.value}";
    }).join('\n\n')}

""";
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

class ParserTokenNotifier {
  final key = uuid.v4();
  final GenerateParserStore store;
  ParserTokenNotifier(this.store);

  final notifier = AppNotifier(
    const ParserToken.def(
      value: TokenValue.and([ParserToken.def()]),
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
      and: (list) => SequenceParser(list.map((e) => _parser(e))),
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
    );
    result = token.repeat.apply(result);
    if (token.negated) {
      result = result.neg();
    }
    if (token.trim) {
      result = result.trim();
    }
    return result;
  }

  late final expression = Computed(() {
    return _expr(value);
  });

  String _expr(ParserToken token) {
    final _inner = token.value.when(
      and: (list) => '(' + list.map((e) => _expr(e)).join(' & ') + ')',
      or: (list) => '(' + list.map((e) => _expr(e)).join(' | ') + ')',
      string: (string, isPattern, caseSensitive) {
        if (caseSensitive) {
          return isPattern ? 'pattern("$string")' : 'string("$string")';
        } else {
          return isPattern
              ? 'patternIgnoreCase("$string")'
              : 'stringIgnoreCase("$string")';
        }
      },
      ref: (ref) => (store.tokens[ref]?.value.name ?? '') + '()',
      predifined: (pred) => pred.toDart(),
    );

    return '$_inner${token.repeat.toDart()}'
        '${token.negated ? ".neg()" : ""}${token.trim ? ".trim()" : ""}';
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
