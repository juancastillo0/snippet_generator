import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snippet_generator/fields/button_select_field.dart';
import 'package:snippet_generator/gen_parsers/gen_parsers_view.dart';
import 'package:snippet_generator/gen_parsers/models/predifined_parsers.dart';
import 'package:snippet_generator/gen_parsers/models/stores.dart';
import 'package:snippet_generator/gen_parsers/models/token_value.dart';
import 'package:snippet_generator/gen_parsers/models/tokens.dart';
import 'package:snippet_generator/utils/extensions.dart';
import 'package:snippet_generator/widgets/portal/custom_overlay.dart';
import 'package:snippet_generator/widgets/portal/global_stack.dart';
import 'package:snippet_generator/widgets/portal/portal_utils.dart';
import 'package:snippet_generator/widgets/small_icon_button.dart';

const _portalParams = PortalParams(
  portalAnchor: Alignment.topCenter,
  childAnchor: Alignment.bottomCenter,
  screenMargin: 10,
  portalWrapper: defaultPortalWrapper,
);

class TokenValueView extends HookWidget {
  const TokenValueView({
    Key? key,
    required this.token,
    required this.onChanged,
    required this.onDelete,
    this.inCollection = false,
  }) : super(key: key);

  final ParserToken token;
  final void Function()? onDelete;
  final void Function(ParserToken) onChanged;
  final bool inCollection;

  @override
  Widget build(BuildContext context) {
    final parser = useSelectedParser();
    final tokenValue = token.value;

    void onChangedValue(TokenValue value) {
      onChanged(token.copyWith(value: value));
    }

    final _deleteIcon = Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: SmallIconButton(
        onPressed: () {
          onDelete?.call();
        },
        child: const Icon(Icons.delete_rounded),
      ),
    );

    final _collectionButtonsRow = Row(
      children: [
        Tooltip(
          message: 'OR',
          child: InkWell(
            onTap: () {
              const toAdd = ParserToken.def();
              onChangedValue(
                tokenValue.maybeWhen(
                  or: (list) => TokenValue.or([
                    ...list,
                    toAdd,
                  ]),
                  orElse: () => TokenValue.or([
                    token,
                    toAdd,
                  ]),
                ),
              );
            },
            child: const Icon(
              Icons.arrow_drop_down_sharp,
              size: 18,
            ),
          ),
        ),
        Tooltip(
          message: 'AND',
          child: InkWell(
            onTap: () {
              const toAdd = ParserToken.def();
              onChangedValue(
                tokenValue.maybeWhen(
                  and: (list, flatten) => TokenValue.and([
                    ...list,
                    toAdd,
                  ], flatten: true),
                  orElse: () => TokenValue.and([
                    token,
                    toAdd,
                  ], flatten: false),
                ),
              );
            },
            child: const Icon(
              Icons.arrow_right,
              size: 18,
            ),
          ),
        ),
      ],
    );

    final inner = FocusTraversalGroup(
      child: tokenValue.maybeMap(
        and: (tokenValue) => Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...tokenValue.values.mapIndex(
              (e, i) => TokenValueView(
                token: e,
                inCollection: true,
                onDelete: () {
                  final _list = [...tokenValue.values];
                  _list.removeAt(i);
                  if (_list.length == 1) {
                    onChanged(_list.first);
                  } else {
                    onChangedValue(TokenValue.and(
                      _list,
                      flatten: tokenValue.flatten,
                    ));
                  }
                },
                onChanged: (v) {
                  final _list = [...tokenValue.values];
                  final _v = v.value;
                  if (_v is TokenValueAnd) {
                    _list[i] = _v.values.first;
                    _list.insertAll(i + 1, _v.values.skip(1));
                  } else {
                    _list[i] = v;
                  }
                  onChangedValue(TokenValue.and(
                    _list,
                    flatten: tokenValue.flatten,
                  ));
                },
              ),
            ),
          ],
        ),
        or: (tokenValue) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...tokenValue.values.mapIndex(
              (e, i) => TokenValueView(
                token: e,
                inCollection: true,
                onDelete: () {
                  final _list = [...tokenValue.values];
                  _list.removeAt(i);
                  if (_list.length == 1) {
                    onChanged(_list.first);
                  } else {
                    onChangedValue(TokenValue.or(_list));
                  }
                },
                onChanged: (v) {
                  final _list = [...tokenValue.values];
                  final _v = v.value;
                  if (_v is TokenValueOr) {
                    _list[i] = _v.values.first;
                    _list.insertAll(i + 1, _v.values.skip(1));
                  } else {
                    _list[i] = v;
                  }
                  onChangedValue(TokenValue.or(_list));
                },
              ),
            ),
          ],
        ),
        separated: (tokenValue) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TokenValueView(
              token: tokenValue.item,
              inCollection: true,
              onDelete: null,
              onChanged: (v) {
                onChangedValue(tokenValue.copyWith(item: v));
              },
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    'Separator',
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
                const SizedBox(width: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Include'),
                    Checkbox(
                      value: tokenValue.includeSeparators,
                      onChanged: (_) {
                        onChangedValue(
                          tokenValue.copyWith(
                            includeSeparators: !tokenValue.includeSeparators,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('At End'),
                    Checkbox(
                      value: tokenValue.optionalSeparatorAtEnd,
                      onChanged: (_) {
                        onChangedValue(
                          tokenValue.copyWith(
                            optionalSeparatorAtEnd:
                                !tokenValue.optionalSeparatorAtEnd,
                          ),
                        );
                      },
                    ),
                  ],
                )
              ],
            ),
            TokenValueView(
              token: tokenValue.separator,
              inCollection: true,
              onDelete: null,
              onChanged: (v) {
                onChangedValue(tokenValue.copyWith(separator: v));
              },
            )
          ],
        ),
        orElse: () {
          final typeStr = tokenValue.maybeMap(
            string: (_) => 'string',
            ref: (_) => 'reference',
            separated: (_) => 'separated',
            predifined: (p) => p.value.toJson(),
            orElse: () => throw Error(),
          );
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
            width: 240,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!tokenValue.isString)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: SizedBox(
                          width: 125,
                          child: TextFormField(
                            initialValue: token.name,
                            onChanged: (value) {
                              onChanged(token.copyWith(name: value));
                            },
                          ),
                        ),
                      ),
                    tokenValue.maybeMap(
                      string: (tokenValue) => Row(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Pattern'),
                              Checkbox(
                                value: tokenValue.isPattern,
                                onChanged: (_) {
                                  onChangedValue(
                                    tokenValue.copyWith(
                                      isPattern: !tokenValue.isPattern,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Cased'),
                              Checkbox(
                                value: tokenValue.caseSensitive,
                                onChanged: (_) {
                                  onChangedValue(
                                    tokenValue.copyWith(
                                      caseSensitive: !tokenValue.caseSensitive,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      predifined: (predifined) => const SizedBox(),
                      orElse: () => const SizedBox(),
                    ),
                    _collectionButtonsRow,
                    if (onDelete != null) _deleteIcon,
                  ],
                ),
                SizedBox(
                  height: 35,
                  child: Row(
                    children: [
                      CustomOverlayButton(
                        builder: StackPortal.make,
                        params: _portalParams,
                        portalBuilder: (notif) {
                          return Column(
                            children: [
                              TextButton(
                                onPressed: () {
                                  if (!tokenValue.isString) {
                                    onChangedValue(const TokenValue.string(
                                      '',
                                      caseSensitive: true,
                                      isPattern: false,
                                    ));
                                  }
                                  notif.hide();
                                },
                                child: const Text('string'),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (!tokenValue.isRef) {
                                    onChangedValue(const TokenValue.ref(''));
                                  }
                                  notif.hide();
                                },
                                child: const Text('reference'),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (!tokenValue.isRef) {
                                    onChangedValue(
                                      const TokenValue.separated(
                                        item: ParserToken.def(),
                                        includeSeparators: false,
                                        optionalSeparatorAtEnd: true,
                                        separator: ParserToken.def(
                                          value: TokenValue.string(
                                            ',',
                                            isPattern: false,
                                            caseSensitive: true,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  notif.hide();
                                },
                                child: const Text('separated'),
                              ),
                              ...PredifinedParser.values.map(
                                (v) => TextButton(
                                  onPressed: () {
                                    onChangedValue(TokenValue.predifined(v));
                                    notif.hide();
                                  },
                                  child: Text(v.toJson()),
                                ),
                              ),
                            ],
                          );
                        },
                        child: SizedBox(
                          width: 110,
                          child: Center(child: Text('Type: $typeStr')),
                        ),
                      ),
                      Expanded(
                        child: tokenValue.maybeMap(
                          ref: (ref) =>
                              CustomDropdownField<ParserTokenNotifier>(
                            asString: (t) => t.value.name,
                            onChange: (t) =>
                                onChangedValue(TokenValue.ref(t.key)),
                            options: parser.tokens.values,
                            selected: parser
                                .tokens[(tokenValue as TokenValueRef).value],
                          ),
                          string: (v) => TextFormField(
                            initialValue: v.value,
                            onChanged: (value) {
                              onChangedValue(TokenValue.string(
                                value,
                                isPattern: v.isPattern,
                                caseSensitive: v.caseSensitive,
                              ));
                            },
                          ),
                          predifined: (predifined) => const SizedBox(),
                          orElse: () => throw Error(),
                        ),
                      ),
                    ],
                  ),
                ),
                BaseTokenConfig(
                  token: token,
                  onChanged: onChanged,
                  direction: Axis.horizontal,
                ),
              ],
            ),
          );
        },
      ),
    );
    final _collectionDecoration = BoxDecoration(
      border: Border.fromBorderSide(BorderSide(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
        width: 2,
      )),
      borderRadius: const BorderRadius.all(Radius.circular(8)),
    );

    if (!tokenValue.isAnd && !tokenValue.isOr && !tokenValue.isSeparated) {
      return inner;
    } else if (tokenValue.isOr || tokenValue.isSeparated) {
      return DecoratedBox(
        decoration: _collectionDecoration,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              // mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 7.0, left: 4, right: 4),
                  child: Text(tokenValue.isSeparated ? 'SEPARATED' : 'CHOICE'),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: 95,
                  child: TextFormField(
                    initialValue: token.name,
                    onChanged: (value) {
                      onChanged(token.copyWith(name: value));
                    },
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    _collectionButtonsRow,
                    _deleteIcon,
                  ],
                ),
                BaseTokenConfig(
                  token: token,
                  onChanged: onChanged,
                  direction: Axis.vertical,
                ),
              ],
            ),
            inner,
          ],
        ),
      );
    } else {
      assert(tokenValue.isAnd);
      final _tokenValue = tokenValue as TokenValueAnd;
      return DecoratedBox(
        decoration: _collectionDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              // mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 7.0),
                  child: Text('SEQUENCE'),
                ),
                const SizedBox(width: 6),
                SizedBox(
                  width: 110,
                  child: TextFormField(
                    initialValue: token.name,
                    onChanged: (value) {
                      onChanged(token.copyWith(name: value));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Row(
                    children: [
                      _collectionButtonsRow,
                      _deleteIcon,
                    ],
                  ),
                ),
                BaseTokenConfig(
                  token: token,
                  onChanged: onChanged,
                  direction: Axis.horizontal,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Flatten'),
                    Checkbox(
                      value: _tokenValue.flatten,
                      onChanged: (_) {
                        onChangedValue(
                          _tokenValue.copyWith(flatten: !_tokenValue.flatten),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            inner,
          ],
        ),
      );
    }
  }
}

class BaseTokenConfig extends StatelessWidget {
  const BaseTokenConfig({
    Key? key,
    required this.token,
    required this.onChanged,
    required this.direction,
  }) : super(key: key);

  final ParserToken token;
  final void Function(ParserToken p1) onChanged;
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    return Flex(
      mainAxisAlignment: direction == Axis.horizontal
          ? MainAxisAlignment.spaceBetween
          : MainAxisAlignment.center,
      direction: direction,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Trim'),
            Checkbox(
              value: token.trim,
              onChanged: (_) {
                onChanged(token.copyWith(trim: !token.trim));
              },
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Neg'),
            Checkbox(
              value: token.negated,
              onChanged: (_) {
                onChanged(token.copyWith(negated: !token.negated));
              },
            ),
          ],
        ),
        CustomOverlayButton(
          builder: StackPortal.make,
          params: _portalParams,
          portalBuilder: (notif) {
            return RepeatForm(
              onChanged: onChanged,
              token: token,
            );
          },
          child: Text(
            'Repeat: ${token.repeat.userString()}',
          ),
        ),
      ],
    );
  }
}
