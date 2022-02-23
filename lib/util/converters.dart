import 'package:fluent_ui/fluent_ui.dart';
import 'package:quiver/collection.dart';

final BiMap<String, ThemeMode> themeModeConverter = BiMap<String, ThemeMode>()
  ..addAll(<String, ThemeMode>{
    'dark': ThemeMode.dark,
    'light': ThemeMode.light,
    'system': ThemeMode.system,
  });
