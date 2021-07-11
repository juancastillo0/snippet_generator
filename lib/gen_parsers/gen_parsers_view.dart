import 'package:flutter/material.dart' hide Action;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:snippet_generator/fields/button_select_field.dart';
import 'package:snippet_generator/gen_parsers/models/stores.dart';
import 'package:snippet_generator/gen_parsers/models/tokens.dart';
import 'package:snippet_generator/gen_parsers/widgets/token_value_view.dart';
import 'package:snippet_generator/types/views/code_generated.dart';
import 'package:snippet_generator/widgets/code_text_field.dart';
import 'package:snippet_generator/widgets/globals.dart';
import 'package:snippet_generator/widgets/horizontal_item_list.dart';
import 'package:snippet_generator/widgets/portal/portal_utils.dart';
import 'package:snippet_generator/widgets/resizable_scrollable/resizable.dart';
import 'package:snippet_generator/widgets/small_icon_button.dart';

class GenerateParserTabView extends HookWidget {
  const GenerateParserTabView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final store = useParserStore();
    final selectedParser = useSelectedParser();

    return Observer(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(
            left: 10.0,
            right: 10.0,
            bottom: 6.0,
          ),
          child: Column(
            children: [
              HookBuilder(builder: (context) {
                useListenable(store.items);
                return Row(
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        store.addValue();
                      },
                      label: const Text('ADD'),
                      icon: const Icon(Icons.add),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: HorizontalItemList<GenerateParserItem>(
                        buildItem: (v) {
                          return Row(
                            children: [
                              SizedBox(
                                width: 80,
                                child: TextField(
                                  controller: v.name.controller,
                                  onTap: () {
                                    store.selectedItem.value = v;
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              SmallIconButton(
                                onPressed: () {
                                  store.removeItem(v);
                                },
                                child: const Icon(
                                  Icons.close,
                                ),
                              )
                            ],
                          );
                        },
                        items: store.items,
                        selected: selectedParser,
                        onSelected: (v, i) {
                          store.selectedItem.value = v;
                        },
                      ),
                    ),
                  ],
                );
              }),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Tokens',
                  style: Theme.of(context).textTheme.headline5,
                ),
              ),
              const SizedBox(height: 12),
              const Expanded(
                child: TokenList(),
              ),
              Resizable(
                defaultHeight: 300,
                vertical: ResizeVertical.top,
                child: Row(
                  children: [
                    Resizable(
                      flex: 1,
                      horizontal: ResizeHorizontal.right,
                      child: CodeGenerated(
                        sourceCode: selectedParser.generateCode(),
                      ),
                    ),
                    Expanded(
                      child: Observer(
                        builder: (context) {
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Test Parser',
                                    style:
                                        Theme.of(context).textTheme.headline6,
                                  ),
                                  Builder(
                                    builder: (context) {
                                      final value = testPod.subscribe(context);

                                      return TextButton(
                                        onPressed: () {
                                          value.value = value.value + 1;
                                        },
                                        child: Text(value.value.toString()),
                                      );
                                    },
                                  ),
                                  SizedBox(
                                    width: 200,
                                    child: CustomDropdownField<
                                        ParserTokenNotifier>(
                                      asString: (t) => t.value.name,
                                      onChange: (t) => selectedParser
                                          .selectedTestTokenKey.value = t.key,
                                      options: selectedParser.tokens.values,
                                      selected: selectedParser
                                          .selectedTestToken.value,
                                    ),
                                  ),
                                ],
                              ),
                              Resizable(
                                flex: 4,
                                vertical: ResizeVertical.bottom,
                                child: CodeTextField(
                                  controller:
                                      selectedParser.parserTestText.controller,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  selectedParser.parserTestResult.value
                                      .toString(),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
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
    final parser = useSelectedParser();
    useListenable(parser.tokenKeys);
    const bottomHeight = 50.0;

    return LayoutBuilder(
      builder: (context, box) {
        return Column(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: box.maxHeight - bottomHeight,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ...parser.tokenKeys.expand(
                      (tokenKey) sync* {
                        // yield Container(
                        //   height: 1,
                        //   color: Theme.of(context)
                        //       .colorScheme
                        //       .onSurface
                        //       .withOpacity(0.1),
                        // );
                        yield Observer(
                          key: Key(tokenKey),
                          builder: (context) {
                            final token = parser.tokens[tokenKey]!;
                            return TokenRow(token: token);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: bottomHeight,
              padding: const EdgeInsets.only(top: 10),
              child: Align(
                alignment: Alignment.topLeft,
                child: OutlinedButton(
                  onPressed: () {
                    parser.addToken();
                  },
                  child: const Text('ADD'),
                ),
              ),
            ),
          ],
        );
      },
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
    final selectedParser = useSelectedParser();

    return FocusTraversalGroup(
      child: Row(
        children: [
          SizedBox(
            width: 160,
            child: TextFormField(
              initialValue: token.value.name,
              decoration: const InputDecoration(labelText: 'Name'),
              onChanged: (value) {
                token.setName(value);
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Resizable(
              vertical: ResizeVertical.bottom,
              defaultHeight: 190,
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
            tooltip: 'Delete',
            onPressed: () {
              selectedParser.removeToken(token.key);
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
          'Optional (?)': RepeatRange.optional(),
          'Plus (+)': RepeatRange.plus(),
          'Star (*)': RepeatRange.star(),
          'Single (1)': RepeatRange.times(1),
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
              child: TextFormField(
                initialValue: token.repeat.min.toString(),
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
              child: TextFormField(
                initialValue: token.repeat.max?.toString(),
                decoration: const InputDecoration(labelText: 'max'),
                onFieldSubmitted: (_) {
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
