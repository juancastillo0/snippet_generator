import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_hooks/flutter_hooks.dart' show HookWidget, useState;
import 'package:snippet_generator/utils/extensions.dart';

// @freezed
// class SelectOption{
//   factory SelectOption.enums()
// }

class ButtonSelect<T> extends HookWidget {
  const ButtonSelect({
    Key? key,
    required this.options,
    required this.selected,
    required this.onChange,
    this.asString,
  }) : super(key: key);

  final Iterable<T> options;
  final T? selected;
  final String Function(T)? asString;
  final void Function(T) onChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDropdown = useState(false);
    final checkedShouldBeDropdown = useState(false);
    double? buttonTop;

    String _asString(T e) =>
        asString == null ? e.toString() : asString!.call(e);

    if (isDropdown.value) {
      return Align(
        child: CustomDropdownField(
          options: options,
          selected: selected,
          asString: _asString,
          onChange: onChange,
        ),
      );
    }

    return Visibility(
      // TODO: can be calculate when we need a dropdown?
      visible: options.length <= 3 || checkedShouldBeDropdown.value,
      maintainState: true,
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: ButtonBar(
          alignment: MainAxisAlignment.center,
          layoutBehavior: ButtonBarLayoutBehavior.constrained,
          buttonPadding: EdgeInsets.zero,
          children: options.map((e) {
            final s = _asString(e);

            return FlatButton(
              key: Key(s),
              onPressed: () => onChange(e),
              color: e == selected ? theme.primaryColor : null,
              child: Builder(builder: (context) {
                SchedulerBinding.instance!.addPostFrameCallback((timeStamp) {
                  // print("Text ${ctx.size} ${ctx.globalPaintBounds}");
                  if (buttonTop == null) {
                    buttonTop = context.globalPaintBounds!.top;
                    return;
                  }
                  if (!checkedShouldBeDropdown.value) {
                    if (buttonTop != context.globalPaintBounds!.top) {
                      isDropdown.value = options.length > 3;
                    }
                    checkedShouldBeDropdown.value = true;
                  }
                });
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: Text(s),
                );
              }),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class CustomDropdownField<T> extends HookWidget {
  final Iterable<T> options;
  final T? selected;
  final String Function(T) asString;
  final void Function(T) onChange;
  final EdgeInsetsGeometry? padding;

  const CustomDropdownField({
    Key? key,
    required this.selected,
    required this.asString,
    required this.onChange,
    required this.options,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isHovering = useState(false);

    final _baseColor = Theme.of(context).colorScheme.onSurface;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => isHovering.value = true,
      onExit: (_) => isHovering.value = false,
      child: Container(
        decoration: BoxDecoration(
          color: isHovering.value
              ? _baseColor.withOpacity(0.08)
              : _baseColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(3),
        ),
        padding: padding ?? const EdgeInsets.only(
          left: 8,
          right: 8,
          bottom: 8,
          top: 7,
        ),
        child: DropdownButton<T>(
          value: selected,
          isExpanded: true,
          isDense: true,
          items: options.map((e) {
            final s = asString(e);
            return DropdownMenuItem<T>(
              value: e,
              child: Center(
                child: Text(
                  s,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) onChange(value);
          },
        ),
      ),
    );
  }
}
