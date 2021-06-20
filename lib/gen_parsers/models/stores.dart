import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mobx/mobx.dart';
import 'package:snippet_generator/gen_parsers/models/predifined_parsers.dart';
import 'package:snippet_generator/gen_parsers/models/token_value.dart';
import 'package:snippet_generator/gen_parsers/models/tokens.dart';
import 'package:snippet_generator/notifiers/app_notifier.dart';
import 'package:snippet_generator/notifiers/collection_notifier/list_notifier.dart';
import 'package:snippet_generator/notifiers/collection_notifier/map_notifier.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

final parserStoreProvider = Provider<GenerateParserStore>(
  (ref) => GenerateParserStore(ref.read),
);

class GenerateParserStore {
  final Reader read;

  GenerateParserStore(this.read) {
    add();
  }

  final tokenKeys = ListNotifier<String>([]);
  final tokens = MapNotifier<String, ParserTokenNotifier>();

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
      });

  String generateCode() {
    final Set<PredifinedParser> predifined = {};

    void _processToken(ParserToken token) {
      token.value.when(
        and: (list) => list.forEach(_processToken),
        or: (list) => list.forEach(_processToken),
        string: (_) {},
        ref: (_) {},
        predifined: (value) {
          predifined.add(value);
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
}

class ParserTokenNotifier {
  final key = uuid.v4();
  final GenerateParserStore store;
  ParserTokenNotifier(this.store);

  final notifier = AppNotifier(const ParserToken.def());

  ParserToken get value => notifier.value;

  late final expression = Computed(() {
    return _expr(value);
  });

  String _expr(ParserToken token) {
    final _inner = token.value.when(
      and: (list) => '(' + list.map((e) => _expr(e)).join(' & ') + ')',
      or: (list) => '(' + list.map((e) => _expr(e)).join(' | ') + ')',
      string: (string) => 'string("$string")',
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
