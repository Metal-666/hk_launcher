Map<String, String> locales = <String, String>{};

Map<String, dynamic> translations = <String, dynamic>{};

String? currentLocale = locales.keys.first;

String tr(List<String> path) {
  Map<String, dynamic> segment = translations;

  for (String element in path) {
    if (segment[element] is Map<String, dynamic>) {
      segment = segment[element];
    } else {
      return '[localization error]';
    }
  }

  dynamic result = segment[currentLocale] ?? segment[locales.keys.first];

  return (result is String) ? result : '[localization error]';
}
