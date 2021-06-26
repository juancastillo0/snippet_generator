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
  add<BorderStyle>((notifier) =>
      EnumInput(notifier: notifier, enumList: BorderStyle.values));
  add<TextStyleEnum>((notifier) =>
      EnumInput(notifier: notifier, enumList: TextStyleEnum.values));

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
  VisualDensity.comfortable: 'comfortable',
  VisualDensity.compact: 'compact',
  VisualDensity.standard: 'standard',
};

class EnumInput<E extends Object> extends StatelessWidget {
  const EnumInput({
    Key? key,
    required this.notifier,
    required this.enumList,
    this.withCard = true,
  }) : super(key: key);

  final PropClass<E?> notifier;
  final List<E> enumList;
  final bool withCard;

  static String _enumToString(Object? e) => e.toString().split('.')[1];

  @override
  Widget build(BuildContext context) {
    final child = ButtonSelect<E>(
      key: ValueKey(notifier.name),
      selected: notifier.value,
      options: enumList,
      asString: _enumToString,
      onChange: notifier.set,
    );
    if (!withCard) {
      return child;
    }
    return DefaultCardInput(
      label: notifier.name,
      children: [
        child,
      ],
    );
  }
}

enum TextStyleEnum {
  headline1,
  headline2,
  headline3,
  headline4,
  headline5,
  headline6,
  subtitle1,
  subtitle2,
  bodyText1,
  bodyText2,
  caption,
  button,
  overline,
}

extension TextStyleEnumTheme on TextStyleEnum {
  String toEnumString() => this.toString().split('.')[1];

  TextStyle? fromTheme(TextTheme theme) {
    switch (this) {
      case TextStyleEnum.headline1:
        return theme.headline1;
      case TextStyleEnum.headline2:
        return theme.headline2;
      case TextStyleEnum.headline3:
        return theme.headline3;
      case TextStyleEnum.headline4:
        return theme.headline4;
      case TextStyleEnum.headline5:
        return theme.headline5;
      case TextStyleEnum.headline6:
        return theme.headline6;
      case TextStyleEnum.subtitle1:
        return theme.subtitle1;
      case TextStyleEnum.subtitle2:
        return theme.subtitle2;
      case TextStyleEnum.bodyText1:
        return theme.bodyText1;
      case TextStyleEnum.bodyText2:
        return theme.bodyText2;
      case TextStyleEnum.caption:
        return theme.caption;
      case TextStyleEnum.button:
        return theme.button;
      case TextStyleEnum.overline:
        return theme.overline;
    }
  }
}
