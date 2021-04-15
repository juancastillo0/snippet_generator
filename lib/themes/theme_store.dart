import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:snippet_generator/notifiers/collection_notifier/list_notifier.dart';
import 'package:snippet_generator/globals/props_serializable.dart';
import 'package:snippet_generator/notifiers/app_notifier.dart';
import 'package:snippet_generator/themes/button_themes.dart';
import 'package:snippet_generator/themes/input_theme.dart';
import 'package:snippet_generator/themes/text_themes.dart';
import 'package:snippet_generator/themes/tooltip_theme.dart';

int _themeCount = 0;

class ThemesStore with PropsSerializable {
  ThemesStore({required this.name});

  final isUsingDarkTheme = AppNotifier(false, name: "isUsingDarkTheme");
  final themes = ListNotifier([ThemeCouple()], propKey: "themes");

  final debugShowMaterialGrid =
      AppNotifier(false, name: "debugShowMaterialGrid");
  final showSemanticsDebugger =
      AppNotifier(false, name: "showSemanticsDebugger");

  @override
  final String name;

  @override
  late final Iterable<SerializableProp> props = [
    isUsingDarkTheme,
    themes,
    debugShowMaterialGrid,
    showSemanticsDebugger,
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

  // COLORS

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
  final dialogBackgroundColor = AppNotifier<Color>(
      _defaultTheme.dialogBackgroundColor,
      name: "dialogBackgroundColor");
  final shadowColor =
      AppNotifier<Color>(_defaultTheme.shadowColor, name: "shadowColor");
  final hintColor = AppNotifier<Color>(_defaultTheme.hintColor, name: "hintColor");
  final focusColor = AppNotifier<Color>(_defaultTheme.focusColor, name: "focusColor");
  final hoverColor = AppNotifier<Color>(_defaultTheme.hoverColor, name: "hoverColor");
  final splashColor = AppNotifier<Color>(_defaultTheme.splashColor, name: "splashColor");
  final disabledColor = AppNotifier<Color>(_defaultTheme.disabledColor, name: "disabledColor");
  final highlightColor = AppNotifier<Color>(_defaultTheme.highlightColor, name: "highlightColor");
  final indicatorColor = AppNotifier<Color>(_defaultTheme.indicatorColor, name: "indicatorColor");
  final selectedRowColor = AppNotifier<Color>(_defaultTheme.selectedRowColor, name: "selectedRowColor");
  final unselectedWidgetColor = AppNotifier<Color>(_defaultTheme.unselectedWidgetColor, name: "unselectedWidgetColor");

  final materialTapTargetSize = AppNotifier<MaterialTapTargetSize>(
      _defaultTheme.materialTapTargetSize,
      name: "materialTapTargetSize");
  final visualDensity = AppNotifier<VisualDensity>(_defaultTheme.visualDensity,
      name: "visualDensity");

  final ColorSchemeNotifier colorScheme;

  final textTheme =
      AppNotifier<TextTheme>(_defaultTheme.textTheme, name: "textTheme");

  final textThemeNotifier = TextThemeNotifier();

  final inputDecorationTheme = InputDecorationThemeNotifier(
      _defaultTheme.inputDecorationTheme,
      name: "inputDecorationTheme");
  final iconTheme =
      AppNotifier<IconThemeData>(_defaultTheme.iconTheme, name: "iconTheme");
  late final tooltipTheme = TooltipThemeNotifier(this,
      name: "tooltipTheme");
  final cardTheme =
      AppNotifier<CardTheme>(_defaultTheme.cardTheme, name: "cardTheme");
  final scrollbarTheme = AppNotifier<ScrollbarThemeData>(
      _defaultTheme.scrollbarTheme,
      name: "scrollbarTheme");
  late final dialogTheme = DialogThemeNotifier(this, "dialogTheme");
  final typography =
      AppNotifier<Typography>(_defaultTheme.typography, name: "typography");
  final snackBarTheme = AppNotifier<SnackBarThemeData>(
      _defaultTheme.snackBarTheme,
      name: "snackBarTheme");
  final bottomSheetTheme = AppNotifier<BottomSheetThemeData>(
      _defaultTheme.bottomSheetTheme,
      name: "bottomSheetTheme");
  late final textButtonTheme =
      TextButtonThemeNotifier(name: "textButtonTheme", themeStore: this);
  late final elevatedButtonTheme = ElevatedButtonThemeNotifier(
      name: "elevatedButtonTheme", themeStore: this);
  late final outlinedButtonTheme = OutlinedButtonThemeNotifier(
      name: "outlinedButtonTheme", themeStore: this);
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
      dialogBackgroundColor: dialogBackgroundColor.value,
      shadowColor: shadowColor.value,
      hintColor: hintColor.value,
      focusColor: focusColor.value,
      hoverColor: hoverColor.value,
      splashColor: splashColor.value,
      disabledColor: disabledColor.value,
      highlightColor: highlightColor.value,
      indicatorColor: indicatorColor.value,
      selectedRowColor: selectedRowColor.value,
      unselectedWidgetColor: unselectedWidgetColor.value,
      //
      materialTapTargetSize: materialTapTargetSize.value,
      visualDensity: visualDensity.value,

      colorScheme: colorScheme.value,
      textTheme: textTheme.value,

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
    dialogBackgroundColor,
    shadowColor,
    hintColor,
    focusColor,
    hoverColor,
    splashColor,
    disabledColor,
    highlightColor,
    indicatorColor,
    selectedRowColor,
    unselectedWidgetColor,
    materialTapTargetSize,
    visualDensity,
    textTheme,
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

class DialogThemeNotifier with PropsSerializable {
  final ThemeStore themeStore;
  @override
  final String name;

  DialogThemeNotifier(this.themeStore, this.name);

  late final AppNotifierWithDefault<Color> backgroundColor =
      AppNotifier.withDefault(() => themeStore.dialogBackgroundColor.value,
          name: "backgroundColor");
  final elevation =
      AppNotifier.withDefault<double>(() => 24.0, name: "elevation");
  late final AppNotifierWithDefault<ShapeBorder> shape =
      AppNotifier.withDefault(
          () => const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
          name: "shape");
  late final AppNotifierWithDefault<TextStyle> titleTextStyle =
      AppNotifier.withDefault(() => themeStore.textTheme.value.headline6!,
          name: "titleTextStyle");
  late final contentTextStyle = TextStyleNotifier(themeStore.textThemeNotifier,
      defaultStyle: () => themeStore.textTheme.value.subtitle1!,
      name: "contentTextStyle");

  DialogTheme get value => computedValue.value;

  late final Computed<DialogTheme> computedValue = Computed(() {
    return DialogTheme(
      backgroundColor: backgroundColor.value,
      elevation: elevation.value,
      shape: shape.value,
      titleTextStyle: titleTextStyle.value,
      contentTextStyle: contentTextStyle.value,
    );
  });

  @override
  late final List<SerializableProp> props = [
    backgroundColor,
    elevation,
    shape,
    titleTextStyle,
    contentTextStyle,
  ];
}
