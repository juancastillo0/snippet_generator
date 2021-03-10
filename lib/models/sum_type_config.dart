import 'package:snippet_generator/models/props_serializable.dart';
import 'package:snippet_generator/notifiers/app_notifier.dart';

class SumTypeConfig with PropsSerializable {
  @override
  final String name;
  SumTypeConfig({required this.name});
  
  @override
  Iterable<AppNotifier<dynamic>> get props =>
      [boolGetters, enumDiscriminant, genericMappers];

  final boolGetters = AppNotifier(true, name: "boolGetters");

  final enumDiscriminant = AppNotifier(true, name: "enumDiscriminant");

  final genericMappers = AppNotifier(true, name: "genericMappers");
}
