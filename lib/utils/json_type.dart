enum PrimitiveJson {
  // ignore: constant_identifier_names
  String,
  int,
  double,
  num,
  custom,
  bool,
}

PrimitiveJson parsePrimitiveJson(String rawString,
    {PrimitiveJson defaultValue = PrimitiveJson.custom}) {
  for (final variant in PrimitiveJson.values) {
    if (variant == PrimitiveJson.custom) continue;
    if (rawString == variant.toEnumString()) {
      return variant;
    }
  }
  return defaultValue;
}

extension PrimitiveJsonExtension on PrimitiveJson {
  String toEnumString() => toString().split(".")[1];
  String enumType() => toString().split(".")[0];

  bool get isString => this == PrimitiveJson.String;
  bool get isInt => this == PrimitiveJson.int;
  bool get isDouble => this == PrimitiveJson.double;
  bool get isNum => this == PrimitiveJson.num;
  bool get isCustom => this == PrimitiveJson.custom;
  bool get isBool => this == PrimitiveJson.bool;

  T? when<T>({
    T Function()? string,
    T Function()? int,
    T Function()? double,
    T Function()? num,
    T Function()? custom,
    T Function()? bool,
    T Function()? orElse,
  }) {
    T Function()? c;
    switch (this) {
      case PrimitiveJson.String:
        c = string;
        break;
      case PrimitiveJson.int:
        c = int;
        break;
      case PrimitiveJson.double:
        c = double;
        break;
      case PrimitiveJson.num:
        c = num;
        break;
      case PrimitiveJson.custom:
        c = custom;
        break;
      case PrimitiveJson.bool:
        c = bool;
        break;

      default:
        c = orElse;
    }
    return (c ?? orElse)?.call();
  }
}
