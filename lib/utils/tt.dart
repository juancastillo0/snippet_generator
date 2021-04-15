import 'package:flutter/material.dart';
import 'package:snippet_generator/globals/props_serializable.dart';
import 'package:snippet_generator/notifiers/app_notifier.dart';
import 'package:snippet_generator/themes/theme_store.dart';

class TooltipThemeNotifier with PropsSerializable {
  TooltipThemeNotifier(ThemeStore theme, {required this.name})
      : heightNotifier = AppNotifier.withDefault(() => 32, name: "height"),
        paddingNotifier = AppNotifier.withDefault(
            () => const EdgeInsets.symmetric(horizontal: 16.0),
            name: "padding"),
        marginNotifier =
            AppNotifier.withDefault(() => EdgeInsets.zero, name: "margin"),
        verticalOffsetNotifier =
            AppNotifier.withDefault(() => 24, name: "verticalOffset"),
        preferBelowNotifier =
            AppNotifier.withDefault(() => true, name: "preferBelow"),
        excludeFromSemanticsNotifier =
            AppNotifier.withDefault(() => false, name: "excludeFromSemantics"),
        decorationNotifier = AppNotifier.withDefault(
            () => BoxDecoration(
                  // TODO: colors.grey[700]
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
            name: "decoration"),
        textStyleNotifier = AppNotifier.withDefault(
            () => theme.textThemeNotifier.bodyText2.value.copyWith(
                  // TODO: colors.white
                  color: Colors.black,
                  fontSize: 14,
                ),
            name: "textStyle"),
        waitDurationNotifier = AppNotifier.withDefault(
            () => const Duration(milliseconds: 1500),
            name: "waitDuration"),
        showDurationNotifier =
            AppNotifier.withDefault(() => Duration.zero, name: "showDuration");

  final AppNotifierWithDefault<double> heightNotifier;
  final AppNotifierWithDefault<EdgeInsetsGeometry> paddingNotifier;
  final AppNotifierWithDefault<EdgeInsetsGeometry> marginNotifier;
  final AppNotifierWithDefault<double> verticalOffsetNotifier;
  final AppNotifierWithDefault<bool> preferBelowNotifier;
  final AppNotifierWithDefault<bool> excludeFromSemanticsNotifier;
  final AppNotifierWithDefault<Decoration> decorationNotifier;
  final AppNotifierWithDefault<TextStyle> textStyleNotifier;
  final AppNotifierWithDefault<Duration> waitDurationNotifier;
  final AppNotifierWithDefault<Duration> showDurationNotifier;

  set value(TooltipThemeData newValue) {
    heightNotifier.value = newValue.height;
    paddingNotifier.value = newValue.padding;
    marginNotifier.value = newValue.margin;
    verticalOffsetNotifier.value = newValue.verticalOffset;
    preferBelowNotifier.value = newValue.preferBelow;
    excludeFromSemanticsNotifier.value = newValue.excludeFromSemantics;
    decorationNotifier.value = newValue.decoration;
    textStyleNotifier.value = newValue.textStyle;
    waitDurationNotifier.value = newValue.waitDuration;
    showDurationNotifier.value = newValue.showDuration;
  }

  TooltipThemeData get value {
    return TooltipThemeData(
      height: heightNotifier.value,
      padding: paddingNotifier.value,
      margin: marginNotifier.value,
      verticalOffset: verticalOffsetNotifier.value,
      preferBelow: preferBelowNotifier.value,
      excludeFromSemantics: excludeFromSemanticsNotifier.value,
      decoration: decorationNotifier.value,
      textStyle: textStyleNotifier.value,
      waitDuration: waitDurationNotifier.value,
      showDuration: showDurationNotifier.value,
    );
  }

  @override
  late final props = [
    heightNotifier,
    paddingNotifier,
    marginNotifier,
    verticalOffsetNotifier,
    preferBelowNotifier,
    excludeFromSemanticsNotifier,
    decorationNotifier,
    textStyleNotifier,
    waitDurationNotifier,
    showDurationNotifier,
  ];

  @override
  final String name;
}
