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
  Future<Directory> move(String path, {bool deleteSource = false}) async {
    await for (final element in list(recursive: true)) {
      if (element is File) {
        final File copy =
            File(join(path, element.path.substring(this.path.length + 1)));
        await copy.parent.create(recursive: true);
        await element.copy(copy.path);
      }
    }

    if (deleteSource) {
      await delete(recursive: true);
    }

    return Directory(path);
  }

  Future<void> showInExplorer() async =>
      Process.run('explorer.exe', <String>[path]);
}

extension LinkExtension on Link {
  Future<Link> set(String target) async {
    if (await exists()) {
      return update(target);
    } else {
      return create(target);
    }
  }
}
