import 'package:flutter/material.dart' hide Action;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snippet_generator/gen_parsers/models/stores.dart';
import 'package:snippet_generator/gen_parsers/models/tokens.dart';
import 'package:snippet_generator/gen_parsers/widgets/token_value_view.dart';
import 'package:snippet_generator/types/views/code_generated.dart';
import 'package:snippet_generator/widgets/globals.dart';
import 'package:snippet_generator/widgets/portal/portal_utils.dart';

class GenerateParserTabView extends HookWidget {
  const GenerateParserTabView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = useProvider(parserStoreProvider);

    return Observer(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Tokens",
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              const SizedBox(height: 12),
              const Expanded(
                child: TokenList(),
              ),
              SizedBox(
                height: 300,
                child: CodeGenerated(
                  sourceCode: store.generateCode(),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

class TokenList extends HookWidget {
  const TokenList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = useProvider(parserStoreProvider);
    useListenable(store.tokenKeys);

    return Column(
      children: [
        ...store.tokenKeys.expand(
          (tokenKey) sync* {
            yield Container(
              height: 1,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            );
            yield Observer(
              key: Key(tokenKey),
              builder: (context) {
                final token = store.tokens[tokenKey]!;
                return TokenRow(token: token);
              },
            );
          },
        ).skip(1),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.topLeft,
          child: OutlinedButton(
            onPressed: () {
              store.add();
            },
            child: const Text("ADD"),
          ),
        ),
      ],
    );
  }
}

class TokenRow extends HookWidget {
  const TokenRow({
    Key? key,
    required this.token,
  }) : super(key: key);

  final ParserTokenNotifier token;

  @override
  Widget build(BuildContext context) {
    final store = useProvider(parserStoreProvider);

    return FocusTraversalGroup(
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: TextField(
              decoration: const InputDecoration(labelText: "Name"),
              onChanged: (value) {
                token.setName(value);
              },
            ),
          ),
          const SizedBox(width: 10),
          // Expanded(
          //   flex: 3,
          //   child: TextField(
          //     decoration:
          //         const InputDecoration(labelText: "RegExp"),
          //     onChanged: (value) {
          //       token.setRegExp(value);
          //     },
          //   ),
          // ),
          // const SizedBox(width: 10),
          // Expanded(
          //   child: Observer(builder: (context) {
          //     return CustomDropdownField<ParserTokenNotifier>(
          //       asString: (t) => t.value.name,
          //       onChange: (t) => token.setRef(t.key),
          //       options: store.tokens.values
          //           .where((t) => t.key != tokenKey),
          //       selected: token.ref.value,
          //     );
          //   }),
          // ),
          const SizedBox(width: 10),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 140),
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Observer(
                    builder: (context) {
                      return TokenValueView(
                        token: token.value,
                        onDelete: null,
                        onChanged: (newValue) =>
                            token.notifier.value = newValue,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            splashRadius: 26,
            tooltip: "Delete",
            onPressed: () {
              store.remove(token.key);
            },
            icon: const Icon(Icons.delete_rounded),
          )
        ],
      ),
    );
  }
}

class RepeatForm extends StatelessWidget {
  const RepeatForm({
    Key? key,
    required this.onChanged,
    required this.token,
  }) : super(key: key);

  final void Function(ParserToken p1) onChanged;
  final ParserToken token;

  @override
  Widget build(BuildContext context) {
    final notif = Inherited.of<PortalNotifier>(context);
    return Column(
      children: [
        ...const {
          "Optional (?)": RepeatRange.optional(),
          "Plus (+)": RepeatRange.plus(),
          "Star (*)": RepeatRange.star()
        }.entries.map(
          (entry) {
            return TextButton(
              onPressed: () {
                onChanged(
                  token.copyWith(repeat: entry.value),
                );
                notif.hide();
              },
              child: Text(entry.key),
            );
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 60,
              child: TextField(
                decoration: const InputDecoration(labelText: 'min'),
                onChanged: (s) {
                  final valueMin = int.tryParse(s);
                  if (valueMin != null && valueMin > 0) {
                    onChanged(
                      token.copyWith(
                        repeat: RepeatRange(
                          valueMin,
                          token.repeat.max,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: TextField(
                decoration: const InputDecoration(labelText: 'max'),
                onSubmitted: (_) {
                  notif.hide();
                },
                onChanged: (s) {
                  final valueMax = int.tryParse(s);
                  if (valueMax != null && valueMax > 0 || s.isEmpty) {
                    onChanged(
                      token.copyWith(
                        repeat: RepeatRange(
                          token.repeat.min,
                          valueMax,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        )
      ],
    );
  }
}
