import 'package:meta/meta.dart';
import 'package:snippet_generator/models/serializer.dart';

class User<V> {
  final String name;
  final int age;
  final V value;

  const User(
    this.age, {
    @required this.name,
    @required this.value,
  });

  User<V> copyWith({
    String name,
    int age,
    V value,
  }) {
    return User(
      age ?? this.age,
      name: name ?? this.name,
      value: value ?? this.value,
    );
  }

  User<V> clone() {
    return User(
      this.age,
      name: this.name,
      value: this.value,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is User<V>) {
      return this.name == other.name &&
          this.age == other.age &&
          this.value == other.value;
    }
    return false;
  }

  @override
  int get hashCode => name.hashCode + age.hashCode + value.hashCode;

  static User<V> fromJson<V>(Map<String, dynamic> map) {
    return User(
      map['age'] as int,
      name: map['name'] as String,
      value: Serializers.fromJson<V>(map['value']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "age": age,
      "value": (value as dynamic).toJson(),
    };
  }
}
