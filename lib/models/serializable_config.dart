import 'package:snippet_generator/models/props_serializable.dart';
import 'package:snippet_generator/notifiers/app_notifier.dart';

class SerializableConfig with PropsSerializable {
  @override
  Iterable<AppNotifier<dynamic>> get props =>
      [staticFunction, returnString, suffix, discriminator];

  final staticFunction = AppNotifier(true, name: "staticFunction");

  final returnString = AppNotifier(false, name: "returnString");

  final suffix = TextNotifier(
    initialText: "Json",
    name: "suffix",
  );

  final discriminator = TextNotifier(
    initialText: "runtimeType",
    name: "discriminator",
  );
}
