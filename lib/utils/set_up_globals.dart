import 'package:snippet_generator/models/models.dart';
import 'package:snippet_generator/themes/theme_store.dart';

void setUpGlobals() {
  Globals.addFactory(() => ThemeCouple());
}
