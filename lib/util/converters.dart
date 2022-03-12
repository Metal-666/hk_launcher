import 'package:fluent_ui/fluent_ui.dart';
import 'package:quiver/collection.dart';

// 'Converts' between a ThemeMode and a String. There probably are other ways to accomplish something like this, but I like this method
final BiMap<String, ThemeMode> themeModeConverter = BiMap<String, ThemeMode>()
  ..addAll(<String, ThemeMode>{
    'dark': ThemeMode.dark,
    'light': ThemeMode.light,
    'system': ThemeMode.system,
  });
