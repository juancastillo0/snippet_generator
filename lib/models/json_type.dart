enum SupportedJsonType {
  // ignore: constant_identifier_names
  String,
  int,
  double,
  num,
  // ignore: constant_identifier_names
  List,
  // ignore: constant_identifier_names
  Map,
  // ignore: constant_identifier_names
  Set,
}

SupportedJsonType? parseSupportedJsonType(String rawString,
    {SupportedJsonType? defaultValue}) {
  for (final variant in SupportedJsonType.values) {
    if (rawString == variant.toEnumString()) {
      return variant;
    }
  }
  return defaultValue;
}

extension SupportedJsonTypeExtension on SupportedJsonType {
  String toEnumString() => toString().split(".")[1];
  String enumType() => toString().split(".")[0];

  bool get isString => this == SupportedJsonType.String;
  bool get isInt => this == SupportedJsonType.int;
  bool get isDouble => this == SupportedJsonType.double;
  bool get isNum => this == SupportedJsonType.num;
  bool get isList => this == SupportedJsonType.List;
  bool get isMap => this == SupportedJsonType.Map;
  bool get isSet => this == SupportedJsonType.Set;

  T? when<T>({
    T Function()? string,
    T Function()? int,
    T Function()? double,
    T Function()? num,
    T Function()? list,
    T Function()? map,
    T Function()? set,
    T Function()? orElse,
  }) {
    T Function()? c;
    switch (this) {
      case SupportedJsonType.String:
        c = string;
        break;
      case SupportedJsonType.int:
        c = int;
        break;
      case SupportedJsonType.double:
        c = double;
        break;
      case SupportedJsonType.num:
        c = num;
        break;
      case SupportedJsonType.List:
        c = list;
        break;
      case SupportedJsonType.Map:
        c = map;
        break;
      case SupportedJsonType.Set:
        c = set;
        break;

      default:
        c = orElse;
    }
    return (c ?? orElse)?.call();
  }
}

final supportedJsonTypes =
    SupportedJsonType.values.map((e) => e.toEnumString()).toSet();
