import 'package:snippet_generator/notifiers/app_notifier.dart';

abstract class PropsSerializable {
  Iterable<AppNotifier<dynamic>> get props;

  Map<String, Object?> toMap() {
    return Map.fromEntries(
      this.props.map((prop) => MapEntry(prop.name, prop.toJson())),
    );
  }

  bool tryFromMap(Map<String, Object?>? json) {
    if (json == null) {
      return false;
    }
    if (this.props.every((prop) => prop.trySetFromMap(json, mutate: false))) {
      for (final prop in this.props) {
        prop.trySetFromMap(json);
      }
      return true;
    }
    return false;
  }
}
