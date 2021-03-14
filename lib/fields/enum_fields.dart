import 'package:flutter/material.dart';
import 'package:snippet_generator/fields/button_select_field.dart';
import 'package:snippet_generator/fields/fields.dart';

const add = GlobalFields.add;

void setUpEnumFields() {
  add<MaterialTapTargetSize>((notifier) =>
      EnumInput(notifier: notifier, enumList: MaterialTapTargetSize.values));

  add<MainAxisAlignment>((notifier) =>
      EnumInput(notifier: notifier, enumList: MainAxisAlignment.values));
  add<CrossAxisAlignment>((notifier) =>
      EnumInput(notifier: notifier, enumList: CrossAxisAlignment.values));
  add<MainAxisSize>((notifier) =>
      EnumInput(notifier: notifier, enumList: MainAxisSize.values));
  add<Axis>((notifier) => EnumInput(notifier: notifier, enumList: Axis.values));
  add<FlexFit>(
      (notifier) => EnumInput(notifier: notifier, enumList: FlexFit.values));
  add<TextOverflow>((notifier) =>
      EnumInput(notifier: notifier, enumList: TextOverflow.values));
  add<TextAlign>(
      (notifier) => EnumInput(notifier: notifier, enumList: TextAlign.values));
  add<TextDirection>((notifier) =>
      EnumInput(notifier: notifier, enumList: TextDirection.values));
  add<VerticalDirection>((notifier) =>
      EnumInput(notifier: notifier, enumList: VerticalDirection.values));
  add<TextBaseline>((notifier) =>
      EnumInput(notifier: notifier, enumList: TextBaseline.values));
  add<Clip>((notifier) => EnumInput(notifier: notifier, enumList: Clip.values));
  add<StackFit>(
      (notifier) => EnumInput(notifier: notifier, enumList: StackFit.values));
  add<Overflow>(
      (notifier) => EnumInput(notifier: notifier, enumList: Overflow.values));
  add<FontStyle>(
      (notifier) => EnumInput(notifier: notifier, enumList: FontStyle.values));
  add<BlurStyle>(
      (notifier) => EnumInput(notifier: notifier, enumList: BlurStyle.values));
  add<BlendMode>(
      (notifier) => EnumInput(notifier: notifier, enumList: BlendMode.values));
  add<StrokeCap>(
      (notifier) => EnumInput(notifier: notifier, enumList: StrokeCap.values));
  add<StrokeJoin>(
      (notifier) => EnumInput(notifier: notifier, enumList: StrokeJoin.values));
  add<FilterQuality>((notifier) =>
      EnumInput(notifier: notifier, enumList: FilterQuality.values));
  add<PaintingStyle>((notifier) =>
      EnumInput(notifier: notifier, enumList: PaintingStyle.values));
  add<TileMode>(
      (notifier) => EnumInput(notifier: notifier, enumList: TileMode.values));
  add<TextDecorationStyle>((notifier) =>
      EnumInput(notifier: notifier, enumList: TextDecorationStyle.values));
  add<FontWeight>(
      (notifier) => EnumInput(notifier: notifier, enumList: FontWeight.values));
  add<FloatingLabelBehavior>((notifier) =>
      EnumInput(notifier: notifier, enumList: FloatingLabelBehavior.values));

  add<VisualDensity>(
    (notifier) => DefaultCardInput(
      label: notifier.name,
      children: [
        ButtonSelect<VisualDensity>(
          key: ValueKey(notifier.name),
          selected: notifier.value,
          options: const [
            VisualDensity.comfortable,
            VisualDensity.compact,
            VisualDensity.standard,
          ],
          asString: (d) {
            return _visualDensityNameMap[d]!;
          },
          onChange: notifier.set,
        ),
      ],
    ),
  );
}

final _visualDensityNameMap = {
  VisualDensity.comfortable: "comfortable",
  VisualDensity.compact: "compact",
  VisualDensity.standard: "standard",
};

class EnumInput<E extends Object> extends StatelessWidget {
  const EnumInput({
    Key? key,
    required this.notifier,
    required this.enumList,
  }) : super(key: key);

  final PropClass<E?> notifier;
  final List<E> enumList;

  static String _enumToString(Object? e) => e.toString().split(".")[1];

  @override
  Widget build(BuildContext context) {
    return DefaultCardInput(
      label: notifier.name,
      children: [
        ButtonSelect<E>(
          key: ValueKey(notifier.name),
          selected: notifier.value,
          options: enumList,
          asString: _enumToString,
          onChange: notifier.set,
        ),
      ],
    );
  }
}
