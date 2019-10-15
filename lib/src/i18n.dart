library i18n_translator;

///
/// Copyright (C) 2019 Andrious Solutions
///
/// This program is free software; you can redistribute it and/or
/// modify it under the terms of the GNU General Public License
/// as published by the Free Software Foundation; either version 3
/// of the License, or any later version.
///
/// You may obtain a copy of the License at
///
///  http://www.apache.org/licenses/LICENSE-2.0
///
///
/// Unless required by applicable law or agreed to in writing, software
/// distributed under the License is distributed on an "AS IS" BASIS,
/// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
/// See the License for the specific language governing permissions and
/// limitations under the License.
///
///          Created  06 Oct 2019
///
///
import 'dart:async' show Future;

import 'dart:io' show Directory, File;

import 'package:flutter/material.dart'
    show
        Key,
        Locale,
        LocalizationsDelegate,
        StrutStyle,
        Text,
        TextAlign,
        TextDirection,
        TextOverflow,
        TextStyle,
        TextWidthBasis;

import 'package:flutter/services.dart' show rootBundle;

import 'package:csv/csv.dart' show CsvToListConverter;

import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory, getTemporaryDirectory;

import 'i18n_translator.dart' show RESERVED_WORDS;

class I18n {
  factory I18n() => _this ??= I18n._();
  static I18n _this;
  I18n._();

  static String _csvFile;
  static String get csvFile {
    if (_csvFile == null || _csvFile.isEmpty) _csvFile = "assets/i18n/i18n.csv";
    return _csvFile;
  }

  static Locale _locale;
  static Map<String, String> _localizedValues;
  static bool _useKey = true;

  static Map<String, Map<String, String>> _allValues;
  static List<String> _locales;

  static Future<bool> init(
      {String csv, Map<String, Map<String, String>> map}) async {
    // Already been called
    if (_I18n.file != null) return true;

    // Process the parameters
    if (_csvFile == null && csv != null && csv.trim().isNotEmpty) {
      _csvFile ??= csv.trim();
      if (_csvFile.indexOf("/") == 0) _csvFile = _csvFile.substring(1);
    }

    if (map != null && map.isNotEmpty) _allValues ??= map;

    _I18n.init(_csvFile);

    bool load;
    try {
      load =
          _allValues == null || _allValues.isEmpty ? await _I18n.load() : true;
    } catch (ex) {
      load = false;
    }
    return load;
  }

  static Future<bool> dispose() => _I18n.dispose();

  /// Load the static Map object with the appropriate translations.
  static Future<I18n> load(Locale locale) {
    _locale = locale;

    String code;

    if (_allValues == null) {
      // No means to get the translations.
      _useKey = true;
      _locales ??= ['en'];
    } else {
      code = _allValues.keys.firstWhere(
          (code) => Locale(code).languageCode == locale.languageCode,
          orElse: () => "");
      _useKey = code.isEmpty;
    }

    _localizedValues = _useKey ? {} : _allValues[code];

    return Future.value(I18n());
  }

  static List<Locale> get supportedLocales =>
      _locales.expand((e) => [Locale(e)]).toList();

//  static I18n of(BuildContext context) => Localizations.of<I18n>(context, I18n);

  /// Supply a Text object for the translation.
  static Text t(
    String data, {
    Key key,
    TextStyle style,
    StrutStyle strutStyle,
    TextAlign textAlign,
    TextDirection textDirection,
    Locale locale,
    bool softWrap,
    TextOverflow overflow,
    double textScaleFactor,
    int maxLines,
    String semanticsLabel,
    TextWidthBasis textWidthBasis,
  }) {
    return Text(
      s(data),
      key: key,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaleFactor: textScaleFactor,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
    );
  }

  /// Translate the String
  static String s(String key) {
    // While developing, return 'null' when appropriate
    // Add key words to a file if not yet found there.
    // assert is removed in production.
    assert(() {
      if (key == null) {
        key = "null";
      }

      if (_I18n.file != null &&
          _useKey &&
          (_allValues == null || _allValues.isEmpty) &&
          _localizedValues != null &&
          _localizedValues[key] == null) {
        _localizedValues.addAll({key: key});
        _I18n.add(key);
      }
      return true;
    }());

    /// If not translation, provide the key itself instead.
    return _useKey ? key ?? "" : _localizedValues[key] ?? key ?? "";
  }

  /// Three properties traditionally found in the Locale object.
  String get languageCode => _locale.languageCode;

  String get countryCode => _locale.countryCode;

  int get hashCode => _locale.hashCode;
}

typedef fileFunc = List<String> Function(File file);

typedef collectFunc = bool Function(
    List<Map<String, String>> maps, List<String> supportedLanguages);

class _I18n {
  static List<String> lines;
  static File file;
  static String contents = "";

  static Future<bool> init(String csvFile) async {
    // Already been called
    if (file != null) return true;

    if (csvFile == null || csvFile.trim().isEmpty) return false;

    String path;
    try {
      Directory directory = await getApplicationDocumentsDirectory();
      path = directory.path + "/";
    } catch (ex) {
      path = "";
    }

    file = File("$path$csvFile");

    bool init = true;

    if (!file.existsSync()) {
      try {
        file.createSync(recursive: true);
      } catch (ex) {
        init = false;
      }
    } else {
      try {
        contents = await file.readAsString();
      } catch (ex) {
        contents = "";
        init = false;
      }
    }
    return init;
  }

  static Future<bool> dispose() async {
    bool write = contents?.trim()?.isNotEmpty ?? false;
    if (!write) return false;
    try {
      await file?.writeAsString(contents, flush: true);
      write = true;
    } catch (ex) {
      write = false;
    }
    return write;
  }

  static Future<bool> add(String word) async {
    if (word == null || word.trim().isEmpty) return false;
    contents += "${word.trim()},\r\n";
    return true;
  }

  static Future<bool> load() async {
    String content;
    try {
      content = await rootBundle.loadString(I18n.csvFile);
      lines = content.split("\r\n");
    } catch (ex) {
      lines = [];
    }

    if (lines.isEmpty) return false;

    bool load = generate(() {
      // Remove any blank lines.
      lines.removeWhere((line) => line.isEmpty);

      if (lines.isEmpty) {
        logError("File is empty:\n ${I18n._csvFile}");
        return lines;
      }
      return lines;
    }, (List<Map<String, String>> maps, List<String> languages) {
      I18n?._locales = languages;

      I18n?._allValues?.clear();

      I18n?._allValues = {};

      Map<String, String> map;
      String lang;

      // Assume the first code is the 'default' language. The rest are the translations.
      List<String> supportedLanguages = languages.sublist(1, languages.length);

      for (var index = 0; index < supportedLanguages.length; index++) {
        lang = supportedLanguages[index];

        map = maps[index];

        if (map == null) break;

        I18n?._allValues?.addAll({lang: map});
      }
      return true;
    });

    return load;
  }

  static bool generate(fileFunc, collectFunc) {
    final List<String> lines = fileFunc();

    if (lines.isEmpty) return false;

    // Get the language codes.
    final List<String> languages = getLineOfWords(lines.first);

    Iterable<String> invalid = languages.where((code) {
      return code.trim().length != 2;
    });

    if (invalid.isNotEmpty) {
      logError("Not valid language code(s):\n $invalid");
      return false;
    }

    // Assume the first code is the 'default' language. The rest are the translations.
    List<String> supportedLanguages = languages.sublist(1, languages.length);

    final List<Map<String, String>> maps = [];

    // Add a Map object the List with every Language.
    supportedLanguages.forEach((_) => maps.add(Map()));

    List<String> lineOfWords;
    String key;
    List<String> words;
    bool noWord;

    for (var linesIndex = 1; linesIndex < lines.length; linesIndex++) {
      lineOfWords = getLineOfWords(lines[linesIndex]);

      // Assume the first word is the key.
      key = lineOfWords.first;

      if (RESERVED_WORDS.contains(key)) {
        logError(
            "$key is a reserved keyword and cannot be used as key (line ${linesIndex + 1})");
        continue;
      }

      // Assume the rest of the words are the translations.
      words = lineOfWords.sublist(1, lineOfWords.length);

      if (words.length != supportedLanguages.length) {
        logError(
            "The line number ${linesIndex + 1} seems malformatted (${words.length} words for ${supportedLanguages.length} columns)");
      }

      for (var wordIndex = 0; wordIndex < words.length; wordIndex++) {
        noWord = words[wordIndex].isEmpty;
        maps[wordIndex][key] = noWord ? key : words[wordIndex];
        if (noWord)
          logError(
              "The line number ${linesIndex + 1} had no word and so key was used: $key");
      }
    }
    // Collect the values from the maps
    return collectFunc(maps, languages);
  }

  static List<String> getLineOfWords(String line) => CsvToListConverter()
      .convert(line)
      .first
      .map((element) => element.toString())
      .toList();

  static Future<File> getTextFileFromAssets(String key) async {
    if (key == null || key.trim().isEmpty) return null;

    key = key.trim();

    if (key.indexOf("/") == 0) {
      key = key.substring(1);
      if (key.trim().isEmpty) return null;
    }

    String content;
    try {
      content = await rootBundle.loadString(key);
    } catch (ex) {
      content = null;
    }

    if (content == null) return null;

    Directory directory = await getTemporaryDirectory();

    File file;
    try {
      file = File("${directory.path}/$key");
      file.writeAsStringSync(content, flush: true);
    } catch (ex) {
      file = null;
    }
    return file;
  }

  static void logError(String text) => print("[ERROR] $text\n\n");

  static void log(String text) => print("[PROGRESS] $text\n");
}

class I18nDelegate extends LocalizationsDelegate<I18n> {
  // No need for more than one instance.
  factory I18nDelegate() {
    _this ??= I18nDelegate._();
    return _this;
  }
  I18nDelegate._();
  static I18nDelegate _this;

  static Locale _locale;
  static bool _reload = false;

  @override
  bool isSupported(Locale locale) {
    // If 'empty' then you're loading the app's locale.
    if (I18n._locales == null || I18n._locales.isEmpty) {
      I18n._locale ??= locale;
      I18n._locales = [locale.languageCode];
      _locale ??= locale;
    }
    return I18n._locales.contains(locale.languageCode);
  }

  @override
  Future<I18n> load(Locale locale) {
    _locale ??= locale;
    _reload = locale != _locale;
    _locale = locale;
    return I18n.load(locale);
  }

  @override
  bool shouldReload(I18nDelegate old) {
    bool reload = _reload;
    if (!reload) reload = this != old;
    _reload = false;
    return reload;
  }
}
