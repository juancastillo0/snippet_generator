import 'package:snippet_generator/notifiers/app_notifier.dart';

class SumTypeConfig {
  static SumTypeConfig fromJson(Map<String, Object> json) {
    if (json == null) {
      return null;
    }
    final sumType = SumTypeConfig();
    if (sumType.props.every((prop) => prop.trySetFromMap(json))) {
      return sumType;
    }
    return null;
  }

  Map<String, Object> toJson() {
    return Map.fromEntries(
      this.props.map((prop) => MapEntry(prop.name, prop.toJson())),
    );
  }

  Iterable<AppNotifier<dynamic>> get props =>
      [boolGetters, enumDiscriminant, discriminator];

  final boolGetters = AppNotifier(true, name: "boolGetters");

  final enumDiscriminant = AppNotifier(true, name: "enumDiscriminant");

  final discriminator = TextNotifier(
    initialText: "runtimeType",
    name: "discriminator",
  );
}
