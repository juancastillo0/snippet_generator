import 'package:flutter/services.dart';

final _variableNameRegex = RegExp(r"^[a-zA-Z_][a-zA-Z_0-9]*");

class Formatters {
  const Formatters._();

  // CUSTOM
  // static final variableName = [FilteringTextInputFormatter.allow(_variableNameRegex)];
  static final variableName = [
    TextInputFormatter.withFunction((oldValue, newValue) {
      final m = _variableNameRegex.firstMatch(newValue.text);
      return m != null || newValue.text.isEmpty
          ? newValue.copyWith(text: m?.group(0) ?? "")
          : oldValue;
    })
  ];

  // SPACES

  static final onlySpaceWhitespace =
      FilteringTextInputFormatter.deny(RegExp(r"(\s)"), replacementString: " ");
  static final noWhitespaces =
      FilteringTextInputFormatter.deny(RegExp(r"(\s)"));
  static final noDoubleSpace = FilteringTextInputFormatter.deny(
      RegExp(r"[ ]{2,}"),
      replacementString: " ");
  static final noStartWhitespaces =
      FilteringTextInputFormatter.allow(RegExp(r"^\S[\s\S]*"));

  // NUMBERS
  static final noStartNumber =
      FilteringTextInputFormatter.allow(RegExp(r"^[^0-9][\s\S]*"));
  static final onlyDigits =
      FilteringTextInputFormatter.allow(RegExp(r"[0-9]+"));
  static final onlyDigitsOrSpace =
      FilteringTextInputFormatter.allow(RegExp(r"[0-9 ]+"));
  static final onlyQuantities =
      FilteringTextInputFormatter.allow(RegExp(r"[1-9][0-9]*"));

  static CustomFormatter onlyDigitsCustom({
    int minLenght = 0,
    int? maxLength,
    String? errorMessage,
  }) {
    return CustomFormatter(onlyDigits, validate: (t) {
      if (t.length >= minLenght && (maxLength == null || t.length <= maxLength)
          // && onlyDigits.whitelistedPattern.matchAsPrefix(t)?.group(0) == t
          ) {
        return null;
      } else {
        return errorMessage;
      }
    });
  }
}

bool Function(String) convertValidate(String? Function(String)? validate) {
  return (String v) => validate!(v) != null;
}

String? Function(String) combineValidators(
  List<String? Function(String)> validators,
) {
  return (String v) {
    for (final validator in validators) {
      final error = validator(v);
      if (error != null) {
        return error;
      }
    }
    return null;
  };
}

class CustomFormatter {
  CustomFormatter(
    this.formatter, {
    String? Function(String)? validate,
  })  : this.validateWithError = validate,
        this.validate = convertValidate(validate);

  final bool Function(String) validate;
  final String? Function(String)? validateWithError;
  final TextInputFormatter formatter;
}
