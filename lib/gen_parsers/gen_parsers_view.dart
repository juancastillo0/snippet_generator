import 'package:flutter/material.dart' hide Action;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart' show runInAction;
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
              Row(
                children: [
                  Text(
                    'Tokens',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  const SizedBox(width: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 200,
                        child: TextField(
                          controller: selectedParser.searchText.controller,
                          focusNode: selectedParser.searchText.focusNode,
                          decoration: const InputDecoration(hintText: 'Search'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Observer(builder: (context) {
                        final search = selectedParser.searchText;
                        return SmallIconButton(
                          onPressed: () {
                            if (search.text.isEmpty) {
                              search.focusNode.requestFocus();
                            } else {
                              search.controller.clear();
                            }
                          },
                          child: Icon(
                            search.text.isEmpty ? Icons.search : Icons.close,
                          ),
                        );
                      })
                    ],
                  ),
                ],
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
    const bottomHeight = 50.0;
    final scrollController = parser.scrollController;

    return Observer(builder: (context) {
      final tokenKeys = parser.filteredTokenKeys.value;
      final isFiltered = parser.isFiltered.value;
      return Column(
        children: [
          Expanded(
            child: Scrollbar(
              controller: scrollController,
              isAlwaysShown: true,
              child: AnimatedBuilder(
                animation: parser.isDragging,
                builder: (context, child) {
                  return Listener(
                    onPointerMove: parser.isDragging.value
                        ? (event) {
                            final renderObject =
                                context.findRenderObject()! as RenderBox;
                            final height = renderObject.size.height;
                            final position = scrollController.position;
                            if (event.localPosition.dy < 30) {
                              final offset = scrollController.offset - 6;
                              if (offset > 0) {
                                scrollController.jumpTo(offset);
                              }
                            } else if (event.localPosition.dy > height - 30) {
                              final offset = scrollController.offset + 6;
                              if (offset < position.maxScrollExtent) {
                                scrollController.jumpTo(offset);
                              }
                            }
                          }
                        : null,
                    child: child,
                  );
                },
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: tokenKeys.length * 2 + 1,
                  itemBuilder: (context, index) {
                    if (index.isEven) {
                      return DragTarget<ParserTokenNotifier>(
                        onAccept: (value) {
                          runInAction(() {
                            final prevIndex = tokenKeys.indexOf(value.key);
                            final newIndex = index ~/ 2;

                            tokenKeys.removeAt(prevIndex);
                            tokenKeys.insert(
                              newIndex > prevIndex ? newIndex - 1 : newIndex,
                              value.key,
                            );
                          });
                        },
                        builder: (context, candidate, rejected) {
                          if (candidate.isNotEmpty && candidate.first != null) {
                            final value = candidate.first!;
                            final theme = Theme.of(context);
                            final style = theme.textTheme.subtitle1!;
                            return Container(
                              padding: const EdgeInsets.all(10.0),
                              margin: const EdgeInsets.only(bottom: 4),
                              color: theme.colorScheme.primary.withOpacity(0.2),
                              child: Text(
                                value.value.name,
                                style: style.copyWith(
                                  color: style.color!.withOpacity(0.7),
                                ),
                              ),
                            );
                          } else {
                            return const SizedBox(
                              height: 10,
                            );
                          }
                        },
                      );
                    }
                    final tokenKey = tokenKeys[index ~/ 2];
                    return Observer(
                      key: Key(tokenKey),
                      builder: (context) {
                        final token = parser.tokens[tokenKey]!;
                        final child = TokenRow(token: token);

                        if (isFiltered) {
                          return child;
                        }

                        return Draggable<ParserTokenNotifier>(
                          feedback: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(token.value.name),
                            ),
                          ),
                          onDragStarted: () {
                            parser.isDragging.value = true;
                          },
                          onDragEnd: (_) {
                            parser.isDragging.value = false;
                          },
                          dragAnchorStrategy: pointerDragAnchorStrategy,
                          axis: Axis.vertical,
                          data: parser.tokens[tokenKey],
                          affinity: Axis.vertical,
                          child: child,
                        );
                      },
                    );
                  },
                ),
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
    });
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Observer(builder: (context) {
                if (selectedParser.isFiltered.value) {
                  return TextButton(
                    onPressed: () {
                      selectedParser.clearSearchAndScrollTo(token);
                    },
                    child: const Text('Scroll to view'),
                  );
                }
                return const InkWell(
                  mouseCursor: SystemMouseCursors.grab,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.drag_indicator_outlined),
                  ),
                );
              }),
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
              const SizedBox(height: 20)
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Resizable(
              vertical: ResizeVertical.bottom,
              defaultHeight: token.widgetHeight,
              onResize: (size) {
                token.widgetHeight = size.height;
              },
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Observer(
                    builder: (context) {
                      return TokenValueView(
                        token: token.value,
                        parentToken: null,
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
          ),
          const SizedBox(width: 10),
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
