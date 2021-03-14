import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snippet_generator/fields/base_fields.dart';
import 'package:snippet_generator/fields/color_field.dart';
import 'package:snippet_generator/fields/fields.dart';

class BorderSideInput extends HookWidget {
  const BorderSideInput({
    Key? key,
    required this.notifier,
  }) : super(key: key);

  final PropClass<BorderSide?> notifier;

  @override
  Widget build(BuildContext context) {
    final value = notifier.value ?? const BorderSide();
    final style = useMemoized(
      () => PropClass.fromNotifier(
        "style",
        ValueNotifier(BorderStyle.solid),
      ),
    );

    return DefaultCardInput(
      label: notifier.name,
      children: [
        DoubleInput(
          label: "width",
          onChanged: (newWidth) {
            if (newWidth != null) {
              notifier.set(value.copyWith(width: newWidth));
            }
          },
          value: notifier.value?.width,
        ),
        const SizedBox(height: 10),
        ColorFieldRow(
          name: "color",
          width: 60,
          onChanged: (color) {
            notifier.set(value.copyWith(color: color));
          },
          value: notifier.value?.color ?? Colors.white,
        ),
        GlobalFields.get(style)!,
      ],
    );
  }
}

class BorderRadiusInput extends HookWidget {
  const BorderRadiusInput({
    Key? key,
    required this.notifier,
  }) : super(key: key);

  final PropClass<BorderRadius?> notifier;

  @override
  Widget build(BuildContext context) {
    final value = notifier.value ?? const BorderRadius.all(Radius.zero);

    void set(BorderRadius newValue) {
      notifier.set(newValue);
    }

    return DefaultCardInput(
      label: notifier.name,
      children: [
        Row(
          children: [
            Expanded(
              child: DoubleInput(
                label: "topLeft",
                value: value.topLeft.x,
                onChanged: (v) {
                  set(value.copyWith(topLeft: Radius.circular(v ?? 0)));
                },
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: DoubleInput(
                label: "top",
                value: value.hasTop ? value.topLeft.x : null,
                onChanged: (v) {
                  if (v != null) {
                    final r = Radius.circular(v);
                    set(value.copyWith(topLeft: r, topRight: r));
                  }
                },
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: DoubleInput(
                label: "topRight",
                value: value.topRight.x,
                onChanged: (v) {
                  set(value.copyWith(topRight: Radius.circular(v ?? 0)));
                },
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: DoubleInput(
                label: "left",
                value: value.bottomLeft.x,
                onChanged: (v) {
                  if (v != null) {
                    final r = Radius.circular(v);
                    set(value.copyWith(topLeft: r, bottomLeft: r));
                  }
                },
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: DoubleInput(
                label: "all",
                value: value.hasAll ? value.topLeft.x : null,
                onChanged: (v) {
                  if (v != null) {
                    final r = Radius.circular(v);
                    set(BorderRadius.all(r));
                  }
                },
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: DoubleInput(
                label: "right",
                value: value.hasRight ? value.topRight.x : null,
                onChanged: (v) {
                  if (v != null) {
                    final r = Radius.circular(v);
                    set(value.copyWith(topRight: r, bottomRight: r));
                  }
                },
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: DoubleInput(
                label: "bottomLeft",
                value: value.bottomLeft.x,
                onChanged: (v) {
                  set(value.copyWith(bottomLeft: Radius.circular(v ?? 0)));
                },
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: DoubleInput(
                label: "bottom",
                value: value.hasBottom ? value.bottomLeft.x : null,
                onChanged: (v) {
                  if (v != null) {
                    final r = Radius.circular(v);
                    set(value.copyWith(bottomLeft: r, bottomRight: r));
                  }
                },
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: DoubleInput(
                label: "bottomRight",
                value: value.bottomRight.x,
                onChanged: (v) {
                  set(value.copyWith(bottomRight: Radius.circular(v ?? 0)));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

extension ExtBorderRadius on BorderRadius {
  bool get hasTop => topRight == topLeft;
  bool get hasBottom => bottomRight == bottomLeft;
  bool get hasLeft => bottomLeft == topLeft;
  bool get hasRight => bottomRight == topRight;
  bool get hasHorizontal => hasLeft && hasRight;
  bool get hasVertical => hasTop && hasBottom;
  bool get hasAll => hasHorizontal && hasVertical;
}
