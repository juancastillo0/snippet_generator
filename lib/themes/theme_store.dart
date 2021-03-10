import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:snippet_generator/collection_notifier/list_notifier.dart';
import 'package:snippet_generator/models/props_serializable.dart';
import 'package:snippet_generator/notifiers/app_notifier.dart';
import 'package:snippet_generator/themes/button_themes.dart';

int _themeCount = 0;

class ThemesStore with PropsSerializable {
  ThemesStore({required this.name});

  final isUsingDarkTheme = AppNotifier(false, name: "isUsingDarkTheme");
  final themes = ListNotifier([ThemeCouple()], propKey: "themes");

  @override
  final String name;

  @override
  late final Iterable<SerializableProp> props = [
    isUsingDarkTheme,
    themes,
  ];
}

class ThemeCouple with ItemsSerializable {
  final light = ThemeStore(brightness: Brightness.light, name: "light");
  final dark = ThemeStore(brightness: Brightness.dark, name: "light");

  final TextNotifier name = TextNotifier(
    initialText: "unnamed${_themeCount++}",
    name: "name",
  );

  @override
  late final Iterable<SerializableProp> props = [
    light,
    dark,
    name,
  ];
}

class ThemeStore with PropsSerializable {
  static final _defaultTheme = ThemeData.light();
  static final _defaultDarkTheme = ThemeData.dark();

  @override
  final String name;
  final Brightness brightness;

  ThemeStore({required this.brightness, required this.name})
      : colorScheme = ColorSchemeNotifier(
          brightness,
          brightness == Brightness.dark
              ? _defaultDarkTheme.colorScheme
              : _defaultTheme.colorScheme,
          name: "colorScheme",
        ) {
    if (brightness == Brightness.dark) {
      runInAction(() {
        this.primaryColor.value = _defaultDarkTheme.primaryColor;
        this.accentColor.value = _defaultDarkTheme.accentColor;
        this.primaryColorLight.value = _defaultDarkTheme.primaryColorLight;
        this.primaryColorDark.value = _defaultDarkTheme.primaryColorDark;
        this.canvasColor.value = _defaultDarkTheme.canvasColor;
        this.scaffoldBackgroundColor.value =
            _defaultDarkTheme.scaffoldBackgroundColor;
        this.cardColor.value = _defaultDarkTheme.cardColor;
        this.buttonColor.value = _defaultDarkTheme.buttonColor;
        this.backgroundColor.value = _defaultDarkTheme.backgroundColor;
        this.errorColor.value = _defaultDarkTheme.errorColor;
        this.toggleableActiveColor.value =
            _defaultDarkTheme.toggleableActiveColor;
      });
    }
  }

  final primaryColor =
      AppNotifier<Color>(_defaultTheme.primaryColor, name: "primaryColor");
  final accentColor =
      AppNotifier<Color>(_defaultTheme.accentColor, name: "accentColor");
  final primaryColorLight = AppNotifier<Color>(_defaultTheme.primaryColorLight,
      name: "primaryColorLight");
  final primaryColorDark = AppNotifier<Color>(_defaultTheme.primaryColorDark,
      name: "primaryColorDark");

  final canvasColor =
      AppNotifier<Color>(_defaultTheme.canvasColor, name: "canvasColor");
  final scaffoldBackgroundColor = AppNotifier<Color>(
      _defaultTheme.scaffoldBackgroundColor,
      name: "scaffoldBackgroundColor");
  final cardColor =
      AppNotifier<Color>(_defaultTheme.cardColor, name: "cardColor");
  final buttonColor =
      AppNotifier<Color>(_defaultTheme.buttonColor, name: "buttonColor");
  final backgroundColor = AppNotifier<Color>(_defaultTheme.backgroundColor,
      name: "backgroundColor");
  final errorColor =
      AppNotifier<Color>(_defaultTheme.errorColor, name: "errorColor");
  final toggleableActiveColor = AppNotifier<Color>(
      _defaultTheme.toggleableActiveColor,
      name: "toggleableActiveColor");

  final ColorSchemeNotifier colorScheme;

  // final colorScheme =
  //     AppNotifier<ColorScheme>(_defaultTheme.colorScheme, name: "colorScheme");

  final inputDecorationTheme = AppNotifier<InputDecorationTheme>(
      _defaultTheme.inputDecorationTheme,
      name: "inputDecorationTheme");
  final iconTheme =
      AppNotifier<IconThemeData>(_defaultTheme.iconTheme, name: "iconTheme");
  final tooltipTheme = AppNotifier<TooltipThemeData>(_defaultTheme.tooltipTheme,
      name: "tooltipTheme");
  final cardTheme =
      AppNotifier<CardTheme>(_defaultTheme.cardTheme, name: "cardTheme");
  final scrollbarTheme = AppNotifier<ScrollbarThemeData>(
      _defaultTheme.scrollbarTheme,
      name: "scrollbarTheme");
  final dialogTheme =
      AppNotifier<DialogTheme>(_defaultTheme.dialogTheme, name: "dialogTheme");
  final typography =
      AppNotifier<Typography>(_defaultTheme.typography, name: "typography");
  final snackBarTheme = AppNotifier<SnackBarThemeData>(
      _defaultTheme.snackBarTheme,
      name: "snackBarTheme");
  final bottomSheetTheme = AppNotifier<BottomSheetThemeData>(
      _defaultTheme.bottomSheetTheme,
      name: "bottomSheetTheme");
  final textButtonTheme = TextButtonThemeNotifier(name: "textButtonTheme");
  final elevatedButtonTheme =
      ElevatedButtonThemeNotifier(name: "elevatedButtonTheme");
  final outlinedButtonTheme =
      OutlinedButtonThemeNotifier(name: "outlinedButtonTheme");
  final textSelectionTheme = AppNotifier<TextSelectionThemeData>(
      _defaultTheme.textSelectionTheme,
      name: "textSelectionTheme");
  final dataTableTheme = AppNotifier<DataTableThemeData>(
      _defaultTheme.dataTableTheme,
      name: "dataTableTheme");
  final checkboxTheme = AppNotifier<CheckboxThemeData>(
      _defaultTheme.checkboxTheme,
      name: "checkboxTheme");
  final radioTheme =
      AppNotifier<RadioThemeData>(_defaultTheme.radioTheme, name: "radioTheme");
  final switchTheme = AppNotifier<SwitchThemeData>(_defaultTheme.switchTheme,
      name: "switchTheme");

  late final themeData = Computed<ThemeData>(() {
    return ThemeData(
      brightness: brightness,
      accentColor: accentColor.value,
      primaryColor: primaryColor.value,
      primaryColorLight: primaryColorLight.value,
      primaryColorDark: primaryColorDark.value,
      //
      canvasColor: canvasColor.value,
      scaffoldBackgroundColor: scaffoldBackgroundColor.value,
      cardColor: cardColor.value,
      buttonColor: buttonColor.value,
      backgroundColor: backgroundColor.value,
      errorColor: errorColor.value,
      toggleableActiveColor: toggleableActiveColor.value,
      //

      colorScheme: colorScheme.value,

      inputDecorationTheme: inputDecorationTheme.value,
      iconTheme: iconTheme.value,
      tooltipTheme: tooltipTheme.value,
      cardTheme: cardTheme.value,
      scrollbarTheme: scrollbarTheme.value,
      dialogTheme: dialogTheme.value,
      typography: typography.value,
      snackBarTheme: snackBarTheme.value,
      bottomSheetTheme: bottomSheetTheme.value,
      textButtonTheme: textButtonTheme.value,
      elevatedButtonTheme: elevatedButtonTheme.value,
      outlinedButtonTheme: outlinedButtonTheme.value,
      textSelectionTheme: textSelectionTheme.value,
      dataTableTheme: dataTableTheme.value,
      checkboxTheme: checkboxTheme.value,
      radioTheme: radioTheme.value,
      switchTheme: switchTheme.value,
    );
  });

  @override
  late final Iterable<SerializableProp> props = [
    primaryColor,
    accentColor,
    primaryColorLight,
    primaryColorDark,
    canvasColor,
    scaffoldBackgroundColor,
    cardColor,
    buttonColor,
    backgroundColor,
    errorColor,
    toggleableActiveColor,
    inputDecorationTheme,
    iconTheme,
    tooltipTheme,
    cardTheme,
    scrollbarTheme,
    dialogTheme,
    typography,
    snackBarTheme,
    colorScheme,
    bottomSheetTheme,
    textButtonTheme,
    elevatedButtonTheme,
    outlinedButtonTheme,
    textSelectionTheme,
    dataTableTheme,
    checkboxTheme,
    radioTheme,
    switchTheme,
  ];
}

class ColorSchemeNotifier with PropsSerializable {
  @override
  final String name;
  final Brightness brightness;

  ColorSchemeNotifier(this.brightness, ColorScheme value, {required this.name})
      : primaryNotifier = AppNotifier<Color>(value.primary, name: "primary"),
        primaryVariantNotifier =
            AppNotifier<Color>(value.primaryVariant, name: "primaryVariant"),
        secondaryNotifier =
            AppNotifier<Color>(value.secondary, name: "secondary"),
        secondaryVariantNotifier = AppNotifier<Color>(value.secondaryVariant,
            name: "secondaryVariant"),
        surfaceNotifier = AppNotifier<Color>(value.surface, name: "surface"),
        backgroundNotifier =
            AppNotifier<Color>(value.background, name: "background"),
        errorNotifier = AppNotifier<Color>(value.error, name: "error"),
        onPrimaryNotifier =
            AppNotifier<Color>(value.onPrimary, name: "onPrimary"),
        onSecondaryNotifier =
            AppNotifier<Color>(value.onSecondary, name: "onSecondary"),
        onSurfaceNotifier =
            AppNotifier<Color>(value.onSurface, name: "onSurface"),
        onBackgroundNotifier =
            AppNotifier<Color>(value.onBackground, name: "onBackground"),
        onErrorNotifier = AppNotifier<Color>(value.onError, name: "onError");

  @override
  late final List<AppNotifier<Color>> props = [
    primaryNotifier,
    primaryVariantNotifier,
    secondaryNotifier,
    secondaryVariantNotifier,
    surfaceNotifier,
    backgroundNotifier,
    errorNotifier,
    onPrimaryNotifier,
    onSecondaryNotifier,
    onSurfaceNotifier,
    onBackgroundNotifier,
    onErrorNotifier,
  ];

  ColorScheme get value => colorSchemeComputed.value;
  late final colorSchemeComputed = Computed(
    () => ColorScheme(
      primary: primary,
      primaryVariant: primaryVariant,
      secondary: secondary,
      secondaryVariant: secondaryVariant,
      surface: surface,
      background: background,
      error: error,
      onPrimary: onPrimary,
      onSecondary: onSecondary,
      onSurface: onSurface,
      onBackground: onBackground,
      onError: onError,
      brightness: brightness,
    ),
  );

  final AppNotifier<Color> primaryNotifier;
  set primary(Color _v) => primaryNotifier.value = _v;
  Color get primary => primaryNotifier.value;
  final AppNotifier<Color> primaryVariantNotifier;
  set primaryVariant(Color _v) => primaryVariantNotifier.value = _v;
  Color get primaryVariant => primaryVariantNotifier.value;
  final AppNotifier<Color> secondaryNotifier;
  set secondary(Color _v) => secondaryNotifier.value = _v;
  Color get secondary => secondaryNotifier.value;
  final AppNotifier<Color> secondaryVariantNotifier;
  set secondaryVariant(Color _v) => secondaryVariantNotifier.value = _v;
  Color get secondaryVariant => secondaryVariantNotifier.value;
  final AppNotifier<Color> surfaceNotifier;
  set surface(Color _v) => surfaceNotifier.value = _v;
  Color get surface => surfaceNotifier.value;
  final AppNotifier<Color> backgroundNotifier;
  set background(Color _v) => backgroundNotifier.value = _v;
  Color get background => backgroundNotifier.value;
  final AppNotifier<Color> errorNotifier;
  set error(Color _v) => errorNotifier.value = _v;
  Color get error => errorNotifier.value;
  final AppNotifier<Color> onPrimaryNotifier;
  set onPrimary(Color _v) => onPrimaryNotifier.value = _v;
  Color get onPrimary => onPrimaryNotifier.value;
  final AppNotifier<Color> onSecondaryNotifier;
  set onSecondary(Color _v) => onSecondaryNotifier.value = _v;
  Color get onSecondary => onSecondaryNotifier.value;
  final AppNotifier<Color> onSurfaceNotifier;
  set onSurface(Color _v) => onSurfaceNotifier.value = _v;
  Color get onSurface => onSurfaceNotifier.value;
  final AppNotifier<Color> onBackgroundNotifier;
  set onBackground(Color _v) => onBackgroundNotifier.value = _v;
  Color get onBackground => onBackgroundNotifier.value;
  final AppNotifier<Color> onErrorNotifier;
  set onError(Color _v) => onErrorNotifier.value = _v;
  Color get onError => onErrorNotifier.value;
}

// class ColorSchemeNotifier extends ValueNotifier<ColorScheme> {
//   ColorSchemeNotifier(ColorScheme value) : super(value);

//   late final p = [primary];

//   set primary(Color _v) => value = value.copyWith(primary: _v);
//   Color get primary => value.primary;
//   set primaryVariant(Color _v) => value = value.copyWith(primaryVariant: _v);
//   Color get primaryVariant => value.primaryVariant;
//   set secondary(Color _v) => value = value.copyWith(secondary: _v);
//   Color get secondary => value.secondary;
//   set secondaryVariant(Color _v) =>
//       value = value.copyWith(secondaryVariant: _v);
//   Color get secondaryVariant => value.secondaryVariant;
//   set surface(Color _v) => value = value.copyWith(surface: _v);
//   Color get surface => value.surface;
//   set background(Color _v) => value = value.copyWith(background: _v);
//   Color get background => value.background;
//   set error(Color _v) => value = value.copyWith(error: _v);
//   Color get error => value.error;
//   set onPrimary(Color _v) => value = value.copyWith(onPrimary: _v);
//   Color get onPrimary => value.onPrimary;
//   set onSecondary(Color _v) => value = value.copyWith(onSecondary: _v);
//   Color get onSecondary => value.onSecondary;
//   set onSurface(Color _v) => value = value.copyWith(onSurface: _v);
//   Color get onSurface => value.onSurface;
//   set onBackground(Color _v) => value = value.copyWith(onBackground: _v);
//   Color get onBackground => value.onBackground;
//   set onError(Color _v) => value = value.copyWith(onError: _v);
//   Color get onError => value.onError;
// }
