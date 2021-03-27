import 'package:snippet_generator/models/props_serializable.dart';
import 'package:snippet_generator/notifiers/app_notifier.dart';

class ListenableConfig with PropsSerializable {
  @override
  final String name;
  ListenableConfig({required this.name});

  @override
  late final List<AppNotifier<dynamic>> props = [
    generateSetters,
    generateGetters,
    generateProps,
    suffix,
    privateNotifiers,
    notifierClass,
  ];

  final generateSetters = AppNotifier(false, name: "setters");
  final generateGetters = AppNotifier(false, name: "getters");
  final generateProps = AppNotifier(true, name: "props");
  final privateNotifiers = AppNotifier(true, name: "privateNotifiers");

  final suffix = TextNotifier(
    initialText: "Notifier",
    name: "suffix",
  );
  final notifierClass = TextNotifier(
    initialText: "ValueNotifier",
    name: "suffix",
  );
}
