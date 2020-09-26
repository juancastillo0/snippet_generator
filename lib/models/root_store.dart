import 'package:snippet_generator/models/models.dart';
import 'package:snippet_generator/models/type_models.dart';

class RootStore {
  final types = ListNotifier<TypeConfig>([]);
  final selectedTypeNotifier = AppNotifier<TypeConfig>(null);
  TypeConfig get selectedType => selectedTypeNotifier.value;

  RootStore() {
    addType();
  }

  void addType() {
    selectedTypeNotifier.value = TypeConfig();
    types.add(selectedTypeNotifier.value);
  }

  void removeType(TypeConfig type) {
    types.remove(type);
    if (types.value.isEmpty){
      addType();
    } else if (type == selectedTypeNotifier.value){
      selectedTypeNotifier.value = types.value[0];
    }
  }

  void selectType(TypeConfig type){
    selectedTypeNotifier.value = type;
  }
}
