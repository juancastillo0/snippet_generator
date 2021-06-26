import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mobx/mobx.dart';
import 'package:snippet_generator/globals/props_serializable.dart';
import 'package:snippet_generator/notifiers/app_notifier.dart';
import 'package:snippet_generator/themes/theme_store.dart';

enum ButtonType {
  text,
  outlined,
  elevated,
}

abstract class BaseButtonThemeNotifier with PropsSerializable {
  final ButtonType type;
  @override
  final String name;

  BaseButtonThemeNotifier(this.type, {required this.name});

  late final alignment = AppNotifier.withDefault<Alignment>(
      () => defaultValue.value.alignment as Alignment,
      name: 'alignment');
  late final elevation = AppNotifier.withDefault<double>(
      () => defaultValue.value.elevation!.resolve({MaterialState.selected})!,
      name: 'elevation');
  late final fixedSize = AppNotifier.withDefault<Size?>(
      () => defaultValue.value.fixedSize?.resolve({MaterialState.selected}),
      name: 'fixedSize');
  late final minimumSize = AppNotifier.withDefault<Size?>(
      () => defaultValue.value.minimumSize?.resolve({MaterialState.selected}),
      name: 'minimumSize');
  late final padding = AppNotifier.withDefault<EdgeInsetsGeometry>(
      () => defaultValue.value.padding!.resolve({MaterialState.selected})!
          as EdgeInsets,
      name: 'padding');
  late final primary = AppNotifier.withDefault<Color>(
      () => type == ButtonType.elevated
          ? defaultValue.value.backgroundColor!
              .resolve({MaterialState.selected})!
          : defaultValue.value.foregroundColor!
              .resolve({MaterialState.selected})!,
      name: 'primary');
  late final onSurface = AppNotifier.withDefault<Color>(
      () => defaultValue.value.foregroundColor!
          .resolve({MaterialState.selected})!,
      name: 'onSurface');
  late final shadowColor = AppNotifier.withDefault<Color>(
      () => defaultValue.value.shadowColor!.resolve({MaterialState.selected})!,
      name: 'shadowColor');
  late final side = AppNotifier.withDefault<BorderSide?>(
      () => defaultValue.value.side?.resolve({MaterialState.selected}),
      name: 'side');
  late final visualDensity = AppNotifier.withDefault<VisualDensity>(
      () => defaultValue.value.visualDensity!,
      name: 'visualDensity');
  late final tapTargetSize = AppNotifier.withDefault<MaterialTapTargetSize>(
      () => defaultValue.value.tapTargetSize!,
      name: 'tapTargetSize');
  late final shape = AppNotifier.withDefault<OutlinedBorder>(
      () => defaultValue.value.shape!.resolve({MaterialState.selected})!,
      name: 'shape');

  Computed<ButtonStyle> get defaultValue;

  static List<SerializableProp> defaultProps(
    BaseButtonThemeNotifier instance,
  ) {
    return [
      instance.alignment,
      instance.elevation,
      instance.fixedSize,
      instance.minimumSize,
      instance.padding,
      instance.primary,
      instance.shadowColor,
      instance.onSurface,
      instance.side,
      instance.visualDensity,
      instance.tapTargetSize,
      instance.shape,
    ];
  }
}

class TextButtonThemeNotifier extends BaseButtonThemeNotifier {
  TextButtonThemeNotifier({required String name, required this.themeStore})
      : super(ButtonType.text, name: name);
  late final backgroundColor = AppNotifier.withDefault<Color>(
      () => defaultValue.value.backgroundColor!
          .resolve({MaterialState.selected})!,
      name: 'backgroundColor');
  final ThemeStore themeStore;

  TextButtonThemeData get value => computed.value;
  late final computed = Computed<TextButtonThemeData>(() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        alignment: alignment.value,
        elevation: elevation.value,
        fixedSize: fixedSize.value,
        minimumSize: minimumSize.value,
        onSurface: onSurface.value,
        padding: padding.value,
        primary: primary.value,
        shadowColor: shadowColor.value,
        side: side.value,
        visualDensity: visualDensity.value,
        tapTargetSize: tapTargetSize.value,
        shape: shape.value,
        backgroundColor: backgroundColor.value,
      ),
    );
  });

  @override
  late final Computed<ButtonStyle> defaultValue = Computed(() {
    final ColorScheme colorScheme = themeStore.colorScheme.value;

    final EdgeInsetsGeometry scaledPadding = ButtonStyleButton.scaledPadding(
        const EdgeInsets.all(8),
        const EdgeInsets.symmetric(horizontal: 8),
        const EdgeInsets.symmetric(horizontal: 4),
        1 // MediaQuery.maybeOf(context)?.textScaleFactor ?? 1,
        );

    return TextButton.styleFrom(
      primary: colorScheme.primary,
      onSurface: colorScheme.onSurface,
      backgroundColor: Colors.transparent,
      shadowColor: themeStore.shadowColor.value,
      elevation: 0,
      textStyle: themeStore.textTheme.value.button,
      padding: scaledPadding,
      minimumSize: const Size(64, 36),
      side: null,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4))),
      enabledMouseCursor: SystemMouseCursors.click,
      disabledMouseCursor: SystemMouseCursors.forbidden,
      visualDensity: themeStore.visualDensity.value,
      tapTargetSize: themeStore.materialTapTargetSize.value,
      animationDuration: kThemeChangeDuration,
      enableFeedback: true,
      alignment: Alignment.center,
      splashFactory: InkRipple.splashFactory,
    );
  });

  @override
  late final List<SerializableProp> props = [
    ...BaseButtonThemeNotifier.defaultProps(this),
    backgroundColor,
  ];
}

class OutlinedButtonThemeNotifier extends BaseButtonThemeNotifier {
  OutlinedButtonThemeNotifier({required String name, required this.themeStore})
      : super(ButtonType.outlined, name: name);
  late final backgroundColor = AppNotifier.withDefault<Color>(
      () => defaultValue.value.backgroundColor!
          .resolve({MaterialState.selected})!,
      name: 'backgroundColor');
  final ThemeStore themeStore;

  OutlinedButtonThemeData get value => computed.value;
  late final computed = Computed<OutlinedButtonThemeData>(() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        alignment: alignment.value,
        elevation: elevation.value,
        fixedSize: fixedSize.value,
        minimumSize: minimumSize.value,
        onSurface: onSurface.value,
        padding: padding.value,
        primary: primary.value,
        shadowColor: shadowColor.value,
        side: side.value,
        visualDensity: visualDensity.value,
        tapTargetSize: tapTargetSize.value,
        shape: shape.value,
        backgroundColor: backgroundColor.value,
      ),
    );
  });

  @override
  late final Computed<ButtonStyle> defaultValue = Computed(() {
    final ColorScheme colorScheme = themeStore.colorScheme.value;

    final EdgeInsetsGeometry scaledPadding = ButtonStyleButton.scaledPadding(
        const EdgeInsets.symmetric(horizontal: 16),
        const EdgeInsets.symmetric(horizontal: 8),
        const EdgeInsets.symmetric(horizontal: 4),
        1 // MediaQuery.maybeOf(context)?.textScaleFactor ?? 1,
        );

    return OutlinedButton.styleFrom(
      primary: colorScheme.primary,
      onSurface: colorScheme.onSurface,
      backgroundColor: Colors.transparent,
      shadowColor: themeStore.shadowColor.value,
      elevation: 0,
      textStyle: themeStore.textTheme.value.button,
      padding: scaledPadding,
      minimumSize: const Size(64, 36),
      side: BorderSide(
        color: themeStore.colorScheme.value.onSurface.withOpacity(0.12),
        width: 1,
      ),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4))),
      enabledMouseCursor: SystemMouseCursors.click,
      disabledMouseCursor: SystemMouseCursors.forbidden,
      visualDensity: themeStore.visualDensity.value,
      tapTargetSize: themeStore.materialTapTargetSize.value,
      animationDuration: kThemeChangeDuration,
      enableFeedback: true,
      alignment: Alignment.center,
      splashFactory: InkRipple.splashFactory,
    );
  });

  @override
  late final List<SerializableProp> props = [
    ...BaseButtonThemeNotifier.defaultProps(this),
    backgroundColor,
  ];
}

class ElevatedButtonThemeNotifier extends BaseButtonThemeNotifier {
  ElevatedButtonThemeNotifier({required String name, required this.themeStore})
      : super(ButtonType.elevated, name: name);
  late final onPrimary = AppNotifier.withDefault<Color>(
      () => defaultValue.value.foregroundColor!
          .resolve({MaterialState.selected})!,
      name: 'onPrimary');
  final ThemeStore themeStore;

  ElevatedButtonThemeData get value => computed.value;
  late final computed = Computed<ElevatedButtonThemeData>(() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        alignment: alignment.value,
        elevation: elevation.value,
        fixedSize: fixedSize.value,
        minimumSize: minimumSize.value,
        onSurface: onSurface.value,
        padding: padding.value,
        primary: primary.value,
        shadowColor: shadowColor.value,
        side: side.value,
        visualDensity: visualDensity.value,
        tapTargetSize: tapTargetSize.value,
        shape: shape.value,
        onPrimary: onPrimary.value,
      ),
    );
  });

  @override
  late final Computed<ButtonStyle> defaultValue = Computed(() {
    final ColorScheme colorScheme = themeStore.colorScheme.value;

    final EdgeInsetsGeometry scaledPadding = ButtonStyleButton.scaledPadding(
        const EdgeInsets.symmetric(horizontal: 16),
        const EdgeInsets.symmetric(horizontal: 8),
        const EdgeInsets.symmetric(horizontal: 4),
        1 //MediaQuery.maybeOf(context)?.textScaleFactor ?? 1,
        );

    return ElevatedButton.styleFrom(
      primary: colorScheme.primary,
      onPrimary: colorScheme.onPrimary,
      onSurface: colorScheme.onSurface,
      shadowColor: themeStore.shadowColor.value,
      elevation: 2,
      textStyle: themeStore.textTheme.value.button,
      padding: scaledPadding,
      minimumSize: const Size(64, 36),
      side: null,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4))),
      enabledMouseCursor: SystemMouseCursors.click,
      disabledMouseCursor: SystemMouseCursors.forbidden,
      visualDensity: themeStore.visualDensity.value,
      tapTargetSize: themeStore.materialTapTargetSize.value,
      animationDuration: kThemeChangeDuration,
      enableFeedback: true,
      alignment: Alignment.center,
      splashFactory: InkRipple.splashFactory,
    );
  });

  @override
  late final List<SerializableProp> props = [
    ...BaseButtonThemeNotifier.defaultProps(this),
    onPrimary,
  ];
}
