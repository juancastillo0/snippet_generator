import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
    final store = useProvider(parserStoreProvider);
    final tokenValue = token.value;

    void onChangedValue(TokenValue value) {
      onChanged(token.copyWith(value: value));
    }

    final inner = tokenValue.maybeWhen(
      and: (list) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...list.mapIndex(
            (e, i) => TokenValueView(
              token: e,
              inCollection: true,
              onDelete: () {
                final _list = [...list];
                _list.removeAt(i);
                if (_list.length == 1) {
                  onChanged(_list.first);
                } else {
                  onChangedValue(TokenValue.and(_list));
                }
              },
              onChanged: (v) {
                final _list = [...list];
                _list[i] = v;
                onChangedValue(TokenValue.and(_list));
              },
            ),
          ),
        ],
      ),
      or: (list) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...list.mapIndex(
            (e, i) => TokenValueView(
              token: e,
              inCollection: true,
              onDelete: () {
                final _list = [...list];
                _list.removeAt(i);
                if (_list.length == 1) {
                  onChanged(_list.first);
                } else {
                  onChangedValue(TokenValue.or(_list));
                }
              },
              onChanged: (v) {
                final _list = [...list];
                _list[i] = v;
                onChangedValue(TokenValue.or(_list));
              },
            ),
          ),
        ],
      ),
      orElse: () {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: tokenValue.isRef
                        ? null
                        : () {
                            onChangedValue(const TokenValue.ref(''));
                          },
                    child: const Text("Ref"),
                  ),
                  TextButton(
                    onPressed: tokenValue.isString
                        ? null
                        : () {
                            onChangedValue(const TokenValue.string(''));
                          },
                    child: const Text("Str"),
                  ),
                  CustomOverlayButton(
                    builder: StackPortal.make,
                    params: _portalParams,
                    portalBuilder: (notif) {
                      return Column(
                        children: [
                          ...PredifinedParser.values.map(
                            (v) => TextButton(
                              onPressed: () {
                                onChangedValue(TokenValue.predifined(v));
                                notif.hide();
                              },
                              child: Text(v.toJson()),
                            ),
                          )
                        ],
                      );
                    },
                    child: const Text("Pred"),
                  ),
                ],
              ),
              SizedBox(
                width: 140,
                height: 35,
                child: Row(
                  children: [
                    Expanded(
                      child: tokenValue.maybeWhen(
                        ref: (ref) => CustomDropdownField<ParserTokenNotifier>(
                          asString: (t) => t.value.name,
                          onChange: (t) =>
                              onChangedValue(TokenValue.ref(t.key)),
                          options: store.tokens.values,
                          selected:
                              store.tokens[(tokenValue as TokenValueRef).value],
                        ),
                        string: (_) => TextField(
                          // decoration: const InputDecoration(labelText: "String"),
                          onChanged: (value) {
                            onChangedValue(TokenValue.string(value));
                          },
                        ),
                        predifined: (predifined) =>
                            Center(child: Text(predifined.toJson())),
                        orElse: () => throw Error(),
                      ),
                    ),
                    if (onDelete != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: SmallIconButton(
                          onPressed: () {
                            onDelete!();
                          },
                          child: const Icon(Icons.delete_rounded),
                        ),
                      )
                  ],
                ),
              ),
              Row(
                children: [
                  const Text("Trim"),
                  Checkbox(
                    value: token.trim,
                    onChanged: (_) {
                      onChanged(token.copyWith(trim: !token.trim));
                    },
                  ),
                  const Text("Neg"),
                  Checkbox(
                    value: token.negated,
                    onChanged: (_) {
                      onChanged(token.copyWith(negated: !token.negated));
                    },
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
                      "Repeat: ${token.repeat.userString()}",
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (inCollection && !tokenValue.isOr) {
      return inner;
    } else {
      return Row(
        children: [
          inner,
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!inCollection || !tokenValue.isOr)
                TextButton(
                  onPressed: () {
                    const toAdd = ParserToken.def(
                      value: TokenValue.string(''),
                    );
                    onChangedValue(
                      tokenValue.maybeWhen(
                        and: (list) => TokenValue.and([
                          ...list,
                          toAdd,
                        ]),
                        orElse: () => TokenValue.and([
                          token,
                          toAdd,
                        ]),
                      ),
                    );
                  },
                  child: const Text("AND"),
                ),
              TextButton(
                onPressed: () {
                  const toAdd = ParserToken.def(
                    value: TokenValue.string(''),
                  );
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
                child: const Text("OR"),
              ),
            ],
          ),
        ],
      );
    }
  }
}
