import 'package:snippet_generator/models/props_serializable.dart';
import 'package:snippet_generator/notifiers/app_notifier.dart';

class SerializableConfig with PropsSerializable {
  @override
  final String name;
  SerializableConfig({required this.name});

  @override
  late final Iterable<AppNotifier<dynamic>> props = [
    staticFunction,
    returnString,
    suffix,
    discriminator,
    generateToJson,
    generateFromJson,
  ];

  final staticFunction = AppNotifier(true, name: "staticFunction");
  final returnString = AppNotifier(false, name: "returnString");
  final generateToJson = AppNotifier(false, name: "toJson");
  final generateFromJson = AppNotifier(false, name: "fromJson");

  final suffix = TextNotifier(
    initialText: "Json",
    name: "suffix",
  );

  final discriminator = TextNotifier(
    initialText: "runtimeType",
    name: "discriminator",
  );
}
