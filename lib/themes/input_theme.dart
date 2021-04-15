import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:snippet_generator/globals/props_serializable.dart';
import 'package:snippet_generator/notifiers/app_notifier.dart';

class InputDecorationThemeNotifier with PropsSerializable {
  @override
  final String name;

  InputDecorationThemeNotifier(InputDecorationTheme value, {required this.name})
      : labelStyleNotifier =
            AppNotifier<TextStyle?>(value.labelStyle, name: "labelStyle"),
        helperStyleNotifier =
            AppNotifier<TextStyle?>(value.helperStyle, name: "helperStyle"),
        helperMaxLinesNotifier =
            AppNotifier<int?>(value.helperMaxLines, name: "helperMaxLines"),
        hintStyleNotifier =
            AppNotifier<TextStyle?>(value.hintStyle, name: "hintStyle"),
        errorStyleNotifier =
            AppNotifier<TextStyle?>(value.errorStyle, name: "errorStyle"),
        errorMaxLinesNotifier =
            AppNotifier<int?>(value.errorMaxLines, name: "errorMaxLines"),
        hasFloatingPlaceholderNotifier = AppNotifier<bool>(
            value.hasFloatingPlaceholder,
            name: "hasFloatingPlaceholder"),
        floatingLabelBehaviorNotifier = AppNotifier<FloatingLabelBehavior>(
            value.floatingLabelBehavior,
            name: "floatingLabelBehavior"),
        isDenseNotifier = AppNotifier<bool>(value.isDense, name: "isDense"),
        contentPaddingNotifier = AppNotifier<EdgeInsets?>(
            // TODO: support EdgeInsetsGeometry
            value.contentPadding as EdgeInsets?,
            name: "contentPadding"),
        isCollapsedNotifier =
            AppNotifier<bool>(value.isCollapsed, name: "isCollapsed"),
        prefixStyleNotifier =
            AppNotifier<TextStyle?>(value.prefixStyle, name: "prefixStyle"),
        suffixStyleNotifier =
            AppNotifier<TextStyle?>(value.suffixStyle, name: "suffixStyle"),
        counterStyleNotifier =
            AppNotifier<TextStyle?>(value.counterStyle, name: "counterStyle"),
        filledNotifier = AppNotifier<bool>(value.filled, name: "filled"),
        fillColorNotifier =
            AppNotifier<Color?>(value.fillColor, name: "fillColor"),
        focusColorNotifier =
            AppNotifier<Color?>(value.focusColor, name: "focusColor"),
        hoverColorNotifier =
            AppNotifier<Color?>(value.hoverColor, name: "hoverColor"),
        errorBorderNotifier =
            AppNotifier<InputBorder?>(value.errorBorder, name: "errorBorder"),
        focusedBorderNotifier = AppNotifier<InputBorder?>(value.focusedBorder,
            name: "focusedBorder"),
        focusedErrorBorderNotifier = AppNotifier<InputBorder?>(
            value.focusedErrorBorder,
            name: "focusedErrorBorder"),
        disabledBorderNotifier = AppNotifier<InputBorder?>(value.disabledBorder,
            name: "disabledBorder"),
        enabledBorderNotifier = AppNotifier<InputBorder?>(value.enabledBorder,
            name: "enabledBorder"),
        borderNotifier =
            AppNotifier<InputBorder?>(value.border, name: "border"),
        alignLabelWithHintNotifier = AppNotifier<bool>(value.alignLabelWithHint,
            name: "alignLabelWithHint");

  InputDecorationTheme get value => computedValue.value;

  late final computedValue = Computed<InputDecorationTheme>(() {
    return InputDecorationTheme(
      labelStyle: labelStyleNotifier.value,
      helperStyle: helperStyleNotifier.value,
      helperMaxLines: helperMaxLinesNotifier.value,
      hintStyle: hintStyleNotifier.value,
      errorStyle: errorStyleNotifier.value,
      errorMaxLines: errorMaxLinesNotifier.value,
      hasFloatingPlaceholder: hasFloatingPlaceholderNotifier.value,
      floatingLabelBehavior: floatingLabelBehaviorNotifier.value,
      isDense: isDenseNotifier.value,
      contentPadding: contentPaddingNotifier.value,
      isCollapsed: isCollapsedNotifier.value,
      prefixStyle: prefixStyleNotifier.value,
      suffixStyle: suffixStyleNotifier.value,
      counterStyle: counterStyleNotifier.value,
      filled: filledNotifier.value,
      fillColor: fillColorNotifier.value,
      focusColor: focusColorNotifier.value,
      hoverColor: hoverColorNotifier.value,
      errorBorder: errorBorderNotifier.value,
      focusedBorder: focusedBorderNotifier.value,
      focusedErrorBorder: focusedErrorBorderNotifier.value,
      disabledBorder: disabledBorderNotifier.value,
      enabledBorder: enabledBorderNotifier.value,
      border: borderNotifier.value,
      alignLabelWithHint: alignLabelWithHintNotifier.value,
    );
  });

  final AppNotifier<TextStyle?> labelStyleNotifier;
  set labelStyle(TextStyle? _v) => labelStyleNotifier.value = _v;
  TextStyle? get labelStyle => labelStyleNotifier.value;
  final AppNotifier<TextStyle?> helperStyleNotifier;
  set helperStyle(TextStyle? _v) => helperStyleNotifier.value = _v;
  TextStyle? get helperStyle => helperStyleNotifier.value;
  final AppNotifier<int?> helperMaxLinesNotifier;
  set helperMaxLines(int? _v) => helperMaxLinesNotifier.value = _v;
  int? get helperMaxLines => helperMaxLinesNotifier.value;
  final AppNotifier<TextStyle?> hintStyleNotifier;
  set hintStyle(TextStyle? _v) => hintStyleNotifier.value = _v;
  TextStyle? get hintStyle => hintStyleNotifier.value;
  final AppNotifier<TextStyle?> errorStyleNotifier;
  set errorStyle(TextStyle? _v) => errorStyleNotifier.value = _v;
  TextStyle? get errorStyle => errorStyleNotifier.value;
  final AppNotifier<int?> errorMaxLinesNotifier;
  set errorMaxLines(int? _v) => errorMaxLinesNotifier.value = _v;
  int? get errorMaxLines => errorMaxLinesNotifier.value;
  final AppNotifier<bool> hasFloatingPlaceholderNotifier;
  set hasFloatingPlaceholder(bool _v) =>
      hasFloatingPlaceholderNotifier.value = _v;
  bool get hasFloatingPlaceholder => hasFloatingPlaceholderNotifier.value;
  final AppNotifier<FloatingLabelBehavior> floatingLabelBehaviorNotifier;
  set floatingLabelBehavior(FloatingLabelBehavior _v) =>
      floatingLabelBehaviorNotifier.value = _v;
  FloatingLabelBehavior get floatingLabelBehavior =>
      floatingLabelBehaviorNotifier.value;
  final AppNotifier<bool> isDenseNotifier;
  set isDense(bool _v) => isDenseNotifier.value = _v;
  bool get isDense => isDenseNotifier.value;
  final AppNotifier<EdgeInsets?> contentPaddingNotifier;
  set contentPadding(EdgeInsets? _v) => contentPaddingNotifier.value = _v;
  EdgeInsets? get contentPadding => contentPaddingNotifier.value;
  final AppNotifier<bool> isCollapsedNotifier;
  set isCollapsed(bool _v) => isCollapsedNotifier.value = _v;
  bool get isCollapsed => isCollapsedNotifier.value;
  final AppNotifier<TextStyle?> prefixStyleNotifier;
  set prefixStyle(TextStyle? _v) => prefixStyleNotifier.value = _v;
  TextStyle? get prefixStyle => prefixStyleNotifier.value;
  final AppNotifier<TextStyle?> suffixStyleNotifier;
  set suffixStyle(TextStyle? _v) => suffixStyleNotifier.value = _v;
  TextStyle? get suffixStyle => suffixStyleNotifier.value;
  final AppNotifier<TextStyle?> counterStyleNotifier;
  set counterStyle(TextStyle? _v) => counterStyleNotifier.value = _v;
  TextStyle? get counterStyle => counterStyleNotifier.value;
  final AppNotifier<bool> filledNotifier;
  set filled(bool _v) => filledNotifier.value = _v;
  bool get filled => filledNotifier.value;
  final AppNotifier<Color?> fillColorNotifier;
  set fillColor(Color? _v) => fillColorNotifier.value = _v;
  Color? get fillColor => fillColorNotifier.value;
  final AppNotifier<Color?> focusColorNotifier;
  set focusColor(Color? _v) => focusColorNotifier.value = _v;
  Color? get focusColor => focusColorNotifier.value;
  final AppNotifier<Color?> hoverColorNotifier;
  set hoverColor(Color? _v) => hoverColorNotifier.value = _v;
  Color? get hoverColor => hoverColorNotifier.value;
  final AppNotifier<InputBorder?> errorBorderNotifier;
  set errorBorder(InputBorder? _v) => errorBorderNotifier.value = _v;
  InputBorder? get errorBorder => errorBorderNotifier.value;
  final AppNotifier<InputBorder?> focusedBorderNotifier;
  set focusedBorder(InputBorder? _v) => focusedBorderNotifier.value = _v;
  InputBorder? get focusedBorder => focusedBorderNotifier.value;
  final AppNotifier<InputBorder?> focusedErrorBorderNotifier;
  set focusedErrorBorder(InputBorder? _v) =>
      focusedErrorBorderNotifier.value = _v;
  InputBorder? get focusedErrorBorder => focusedErrorBorderNotifier.value;
  final AppNotifier<InputBorder?> disabledBorderNotifier;
  set disabledBorder(InputBorder? _v) => disabledBorderNotifier.value = _v;
  InputBorder? get disabledBorder => disabledBorderNotifier.value;
  final AppNotifier<InputBorder?> enabledBorderNotifier;
  set enabledBorder(InputBorder? _v) => enabledBorderNotifier.value = _v;
  InputBorder? get enabledBorder => enabledBorderNotifier.value;
  final AppNotifier<InputBorder?> borderNotifier;
  set border(InputBorder? _v) => borderNotifier.value = _v;
  InputBorder? get border => borderNotifier.value;
  final AppNotifier<bool> alignLabelWithHintNotifier;
  set alignLabelWithHint(bool _v) => alignLabelWithHintNotifier.value = _v;
  bool get alignLabelWithHint => alignLabelWithHintNotifier.value;

  @override
  Iterable<SerializableProp> get props => [
        labelStyleNotifier,
        helperStyleNotifier,
        helperMaxLinesNotifier,
        hintStyleNotifier,
        errorStyleNotifier,
        errorMaxLinesNotifier,
        hasFloatingPlaceholderNotifier,
        floatingLabelBehaviorNotifier,
        isDenseNotifier,
        contentPaddingNotifier,
        isCollapsedNotifier,
        prefixStyleNotifier,
        suffixStyleNotifier,
        counterStyleNotifier,
        filledNotifier,
        fillColorNotifier,
        focusColorNotifier,
        hoverColorNotifier,
        errorBorderNotifier,
        focusedBorderNotifier,
        focusedErrorBorderNotifier,
        disabledBorderNotifier,
        enabledBorderNotifier,
        borderNotifier,
        alignLabelWithHintNotifier,
      ];
}
