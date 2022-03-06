import 'dart:io';

import 'package:path/path.dart';

String hkExePath(String rootPath, int version) {
  switch (version) {
    case 14:
      {
        return join(rootPath, 'hollow_knight.exe');
      }
    case 15:
      {
        return join(rootPath, 'Hollow Knight.exe');
      }
  }
  return '';
}

String hkDataPath(String rootPath, int version) {
  switch (version) {
    case 14:
      {
        return join(rootPath, 'hollow_knight_Data');
      }
    case 15:
      {
        return join(rootPath, 'Hollow Knight_Data');
      }
  }
  return '';
}

String hkModpacksPath(String rootPath) => join(rootPath, 'Modpacks');

String hkManagedPath(String rootPath, int version) =>
    join(hkDataPath(rootPath, version), 'Managed');

String hkModpackPath(String rootPath, String modpack) =>
    join(hkModpacksPath(rootPath), modpack);

String hkModpackManagedPath(String rootPath, String modpack) =>
    join(hkModpackPath(rootPath, modpack), 'Managed');

String hkSavesPath() => join(Platform.environment['UserProfile']!, 'AppData',
    'LocalLow', 'Team Cherry', 'Hollow Knight');

String hkModpackSavesPath(String rootPath, String modpack) =>
    join(hkModpackPath(rootPath, modpack), 'Hollow Knight');
