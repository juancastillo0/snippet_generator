
import 'package:flutter/material.dart';
import 'package:snippet_generator/globals/props_serializable.dart';
import 'package:snippet_generator/globals/serializer.dart';
import 'package:snippet_generator/notifiers/app_notifier.dart';

class AdvancedTypeConfig
    with PropsSerializable
    implements Serializable<AdvancedTypeConfig> {
  @override
  final String name;
  late final TextNotifier customCodeNotifier;
  String get customCode => customCodeNotifier.text;

  late final AppNotifier<bool> overrideConstructorNotifier;
  bool get overrideConstructor => overrideConstructorNotifier.value;

  late final AppNotifier<bool> isConstNotifier;
  bool get isConst => isConstNotifier.value;

  late final Listenable _listenable;
  Listenable get listenable => _listenable;

  AdvancedTypeConfig({
    String? customCode,
    bool? overrideConstructor,
    bool? isConst,
    required this.name,
  }) {
    overrideConstructorNotifier = AppNotifier(overrideConstructor ?? false,
        parent: this, name: 'overrideConstructor');
    customCodeNotifier =
        TextNotifier(initialText: customCode, parent: this, name: 'customCode');
    isConstNotifier =
        AppNotifier(isConst ?? true, parent: this, name: 'isConst');

    _listenable = Listenable.merge([
      overrideConstructorNotifier,
      customCodeNotifier.textNotifier,
      isConstNotifier,
    ]);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'customCode': customCode,
      'overrideConstructor': overrideConstructor,
      'isConst': isConst,
    };
  }

  @override
  late final props = [
    customCodeNotifier,
    overrideConstructorNotifier,
    isConstNotifier,
  ];
}