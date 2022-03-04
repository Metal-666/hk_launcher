import 'dart:developer';
import 'dart:io';
import 'package:path/path.dart';

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';

  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

extension DirectoryExtension on Directory {
  Future<Directory> move(String path) async {
    await for (final element in list(recursive: true)) {
      if (element is File) {
        final File copy =
            File(join(path, element.path.substring(this.path.length + 1)));
        await copy.parent.create(recursive: true);
        await element.copy(copy.path);
      }
    }
    await delete(recursive: true);
    return Directory(path);
  }
}
