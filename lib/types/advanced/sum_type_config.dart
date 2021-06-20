import 'package:snippet_generator/globals/props_serializable.dart';
import 'package:snippet_generator/notifiers/app_notifier.dart';

class SumTypeConfig with PropsSerializable {
  @override
  final String name;
  SumTypeConfig({required this.name});
  
  @override
  Iterable<AppNotifier<dynamic>> get props =>
      [boolGetters, enumDiscriminant, genericMappers, prefix, suffix];

  final boolGetters = AppNotifier(true, name: "boolGetters");

  final enumDiscriminant = AppNotifier(true, name: "enumDiscriminant");

  final genericMappers = AppNotifier(true, name: "genericMappers");

  final prefix = TextNotifier(name: "prefix");
  
  final suffix = TextNotifier(name: "suffix");
}
