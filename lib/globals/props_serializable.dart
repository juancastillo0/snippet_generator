abstract class SerializableItem {
  Object? toJson();
  bool trySetFromJson(Object? json);
}

abstract class SerializableProp implements SerializableItem {
  String get name;
  @override
  Object? toJson();
  @override
  bool trySetFromJson(Object? json);
}

abstract class PropsSerializable implements SerializableProp {
  Iterable<SerializableProp> get props;

  @override
  Map<String, Object?> toJson() {
    return Map.fromEntries(
      this.props.map((prop) => MapEntry(prop.name, prop.toJson())),
    );
  }

  @override
  bool trySetFromJson(Object? json) {
    if (json is! Map<String, Object?>) {
      return false;
    }
    return this.props.every((prop) => prop.trySetFromJson(json[prop.name]));
  }
}

abstract class ItemsSerializable implements SerializableItem {
  Iterable<SerializableProp> get props;

  @override
  Map<String, Object?> toJson() {
    return Map.fromEntries(
      this.props.map((prop) => MapEntry(prop.name, prop.toJson())),
    );
  }

  @override
  bool trySetFromJson(Object? json) {
    if (json is! Map<String, Object?>) {
      return false;
    }
    return this.props.every((prop) => prop.trySetFromJson(json[prop.name]));
  }
}
