import 'package:snippet_generator/globals/props_serializable.dart';
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

  final staticFunction = AppNotifier(true, name: 'staticFunction');
  final returnString = AppNotifier(false, name: 'returnString');
  final generateToJson = AppNotifier(true, name: 'toJson');
  final generateFromJson = AppNotifier(true, name: 'fromJson');

  final suffix = TextNotifier(
    initialText: 'Json',
    name: 'suffix',
  );

  final discriminator = TextNotifier(
    initialText: 'runtimeType',
    name: 'discriminator',
  );
}
