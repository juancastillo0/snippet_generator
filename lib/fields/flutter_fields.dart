import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:snippet_generator/fields/base_fields.dart';
import 'package:snippet_generator/fields/fields.dart';
import 'package:snippet_generator/parsers/flutter_props_parsers.dart';

class AlignmentInput extends HookWidget {
  const AlignmentInput({
    required ValueKey<String> key,
    Alignment? value,
    required this.set,
  })   : value = value ?? const Alignment(0, 0),
        super(key: key);

  @override
  ValueKey<String> get key => super.key as ValueKey<String>;

  final void Function(Alignment) set;
  final Alignment value;

  @override
  Widget build(BuildContext context) {
    final controllerL = useTextEditingController();
    final controllerR = useTextEditingController();

    useEffect(() {
      if (double.tryParse(controllerL.text) != value.x) {
        controllerL.value =
            controllerL.value.copyWith(text: value.x.toString());
      }
      if (double.tryParse(controllerR.text) != value.y) {
        controllerR.value =
            controllerR.value.copyWith(text: value.y.toString());
      }
      return () {};
    }, [value]);

    return Card(
      child: Container(
        width: 200,
        height: 150,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(key.value),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controllerL,
                    decoration: const InputDecoration(labelText: "delta x"),
                    onChanged: (String dx) {
                      final dxNum = double.tryParse(dx);
                      if (dxNum != null) {
                        set(Alignment(dxNum, value.y));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: TextField(
                    controller: controllerR,
                    decoration: const InputDecoration(labelText: "delta y"),
                    onChanged: (String dy) {
                      final dyNum = double.tryParse(dy);
                      if (dyNum != null) {
                        set(Alignment(value.x, dyNum));
                      }
                    },
                  ),
                ),
              ],
            ),
            DropdownButton<Alignment>(
              value: alignmentList.contains(value) ? value : null,
              items: alignmentList
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      key: ValueKey(e),
                      child: Text(e.toString().split(".")[1]),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v != null) set(v);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PaddingInput extends HookWidget {
  const PaddingInput({
    required ValueKey<String> key,
    EdgeInsets? value,
    required this.set,
  })   : value = value ?? EdgeInsets.zero,
        super(key: key);

  final EdgeInsets value;
  final void Function(EdgeInsets) set;

  @override
  Widget build(BuildContext context) {
    final key = this.key as ValueKey<String>;

    return Card(
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(key.value),
            ),
            Row(
              children: [
                Expanded(
                  child: DoubleInput(
                    label: "horizontal",
                    value: value.hasHorizontal ? value.left : null,
                    onChanged: (v) {
                      set(value.copyWith(left: v, right: v));
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: DoubleInput(
                    label: "top",
                    value: value.top,
                    onChanged: (v) {
                      set(value.copyWith(top: v));
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: DoubleInput(
                    label: "vertical",
                    value: value.hasVertical ? value.top : null,
                    onChanged: (v) {
                      set(value.copyWith(top: v, bottom: v));
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
                    value: value.left,
                    onChanged: (v) {
                      set(value.copyWith(left: v));
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: DoubleInput(
                    label: "all",
                    value: value.hasAll ? value.left : null,
                    onChanged: (v) {
                      // TODO:
                      set(EdgeInsets.all(v ?? 0));
                    },
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: DoubleInput(
                    label: "right",
                    value: value.right,
                    onChanged: (v) {
                      set(value.copyWith(right: v));
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Spacer(),
                const SizedBox(width: 15),
                Expanded(
                  child: DoubleInput(
                    label: "bottom",
                    value: value.bottom,
                    onChanged: (v) {
                      set(value.copyWith(bottom: v));
                    },
                  ),
                ),
                const SizedBox(width: 15),
                const Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

extension ExtEdgeInsets on EdgeInsets {
  bool get hasHorizontal => left == right;
  bool get hasVertical => top == bottom;
  bool get hasAll => left == right && top == bottom && left == bottom;
}

class SizeInput extends StatelessWidget {
  const SizeInput({
    Key? key,
    required this.notifier,
  }) : super(key: key);
  final PropClass<Size?> notifier;

  @override
  Widget build(BuildContext context) {
    return DefaultCardInput(
      label: notifier.name,
      children: [
        DoubleInput(
          label: "width",
          onChanged: (w) => notifier.set(
            w == null ? null : Size(w, notifier.value?.height ?? 0),
          ),
          value: notifier.value?.width,
        ),
        DoubleInput(
          label: "height",
          onChanged: (h) => notifier.set(
            h == null ? null : Size(notifier.value?.width ?? 0, h),
          ),
          value: notifier.value?.height,
        )
      ],
    );
  }
}

// class TextStyleInput extends HookWidget {
//   const TextStyleInput({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final textTheme = Theme.of(context).textTheme;
//     final style = useState(TextStyleEnum.bodyText1);

//     return ButtonSelect<TextStyleEnum>(
//       onChange: (v) => style.value = v,
//       options: TextStyleEnum.values,
//       asString: (b) => b.toEnumString(),
//       selected: style.value,
//     );
//   }
// }

class ColorInput extends StatelessWidget {
  const ColorInput({
    Key? key,
    required this.notifier,
  }) : super(key: key);
  final PropClass<Color?> notifier;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(notifier.name),
            ),
            const SizedBox(height: 5),
            Builder(builder: (context) {
              final mq = MediaQuery.of(context);
              return MediaQuery(
                data: mq.copyWith(size: Size(250, mq.size.height)),
                child: ColorPicker(
                  pickerColor: notifier.value ?? Colors.black,
                  onColorChanged: notifier.set,
                  colorPickerWidth: 250.0,
                  pickerAreaHeightPercent: 0.7,
                  enableAlpha: true,
                  displayThumbColor: true,
                  showLabel: true,
                  paletteType: PaletteType.hsv,
                  pickerAreaBorderRadius: const BorderRadius.all(
                    Radius.circular(4.0),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
