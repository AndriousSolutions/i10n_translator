library i10n_translator;

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

import 'dart:io' show Directory, File, Platform;

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

import 'package:path/path.dart' as p;

import 'package:path_provider/path_provider.dart'
    show
        getApplicationDocumentsDirectory,
        getExternalStorageDirectory;

import 'package:i10n_translator/src/i10n_translator.dart' show RESERVED_WORDS;

class I10n {
  factory I10n() => _this;
  static final I10n _this = I10n._();
  I10n._();

  static String _csvFile;
  static String get csvFile {
    if (_csvFile == null || _csvFile.isEmpty)
      _csvFile = p.join("assets", "i10n", "i10n.csv");
    return _csvFile;
  }

  static Exception _ex;
  static Locale _locale;
  static Map<String, String> _localizedValues;
  static bool _useKey = true;

  static Map<String, Map<String, String>> _allValues;
  static List<String> _locales;

  static Future<bool> init(
      {String csv, Map<String, Map<String, String>> map}) async {
    // Already been called
    if ((_allValues != null && _allValues.isNotEmpty) || _I10n.file != null)
      return false;

    // Assign the csv file if not already assigned
    if (_csvFile == null && csv != null && csv.trim().isNotEmpty) {
      _csvFile = csv.trim();
      // If no path, set a path
      if (p.dirname(_csvFile) == '.') {
        _csvFile = p.join("assets", "i10n", p.basename(_csvFile));
      } else if (_csvFile.indexOf(p.separator) == 0)
        _csvFile = _csvFile.substring(1);
      // If no file extension, add it.
      _csvFile = p.setExtension(_csvFile, ".csv");
    }

    // Assign the map if not already assigned
    if (map != null && map.isNotEmpty) _allValues ??= map;

    bool init = true;

    if (_allValues == null || _allValues.isEmpty) {
      if (_csvFile != null && _csvFile.isNotEmpty) {
        // Open a csv file to place in entries.
        _I10n.init(p.basename(_csvFile));
      }
      try {
        // Open an asset if any to read in the entries.
        init = await _I10n.load();
      } catch (ex) {
        init = false;
      }
    }

    if (_allValues != null)
      _locales ??= _allValues.keys.expand((e) => [e]).toList();

    return init;
  }

  static List<Locale> get supportedLocales =>
      _locales == null ? null : _locales.expand((e) => [Locale(e)]).toList();

  static Future<bool> dispose() => _I10n.dispose();

  /// Load the static Map object with the appropriate translations.
  static Future<I10n> load(Locale locale) {
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

    return Future.value(I10n());
  }

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

      if (_I10n.file != null &&
          _useKey &&
          (_allValues == null || _allValues.isEmpty) &&
          _localizedValues != null &&
          _localizedValues[key] == null) {
        _localizedValues.addAll({key: key});
        _I10n.add(key);
      }
      return true;
    }());

    /// If not translation, provide the key itself instead.
    return _useKey ? key ?? "" : _localizedValues[key] ?? key ?? "";
  }

  /// The current Locale object.
  static Locale get locale => _locale;

  Object get message => _ex?.toString() ?? "";

  static bool inError() => _ex != null;

  static Exception getError() {
    var e = _ex;
    _ex = null;
    return e;
  }
}

typedef fileFunc = List<String> Function(File file);

typedef collectFunc = bool Function(
    List<Map<String, String>> maps, List<String> supportedLanguages);

class _I10n {
  static List<String> lines;
  static File file;
  static String contents = "";

  static Future<bool> init(String csvFile) async {
    // Already been called
    if (file != null) return true;
    // Process the parameter
    if (csvFile == null || csvFile.trim().isEmpty) return false;

    String path;
    try {
      Directory directory;
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getExternalStorageDirectory();
      }
      path = directory.path; //+ p.separator;
    } catch (ex) {
      path = "";
    }

    if (path.isEmpty) return false;

    path = p.join(path, csvFile);

    file = File(path);

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
      content = await rootBundle.loadString(I10n.csvFile);
      lines = content.split("\r\n");
    } catch (ex) {
      lines = [];
    }

    if (lines.isEmpty) return false;

    bool load = generate(() {
      // Remove any blank lines.
      lines.removeWhere((line) => line.isEmpty);

      if (lines.isEmpty) {
        logError("File is empty:\n ${I10n._csvFile}");
        return lines;
      }
      return lines;
    }, (List<Map<String, String>> maps, List<String> languages) {
      I10n?._locales = languages;

      I10n?._allValues?.clear();

      I10n?._allValues = {};

      Map<String, String> map;
      String lang;

      // Assume the first code is the 'default' language. The rest are the translations.
      List<String> supportedLanguages = languages.sublist(1, languages.length);

      for (var index = 0; index < supportedLanguages.length; index++) {
        lang = supportedLanguages[index];

        map = maps[index];

        if (map == null) break;

        I10n?._allValues?.addAll({lang: map});
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

//  static Future<File> getTextFileFromAssets(String key) async {
//    if (key == null || key.trim().isEmpty) return null;
//
//    key = key.trim();
//
//    if (key.indexOf("/") == 0) {
//      key = key.substring(1);
//      if (key.trim().isEmpty) return null;
//    }
//
//    String content;
//    try {
//      content = await rootBundle.loadString(key);
//    } catch (ex) {
//      content = null;
//    }
//
//    if (content == null) return null;
//
//    Directory directory = await getTemporaryDirectory();
//
//    File file;
//    try {
//      file = File("${directory.path}/$key");
//      file.writeAsStringSync(content, flush: true);
//    } catch (ex) {
//      file = null;
//    }
//    return file;
//  }

  static void logError(String text) => print("[I10n ERROR] $text\r\n");
}

class I10nDelegate extends LocalizationsDelegate<I10n> {
  // No need for more than one instance.
  factory I10nDelegate() => _this ??= I10nDelegate._();
  static I10nDelegate _this;
  I10nDelegate._();

  static Locale _locale;
  static bool _reload = false;

  @override
  bool isSupported(Locale locale) {
    // If 'I10n._locale == null' then you're loading the app's locale.
    if (I10n._locale == null) {
      I10n._locale = locale;

      if (I10n._locales == null || I10n._locales.isEmpty) {
        I10n._locales = [locale.languageCode];
      } else if (!I10n._locales.contains(locale.languageCode))
        I10n._locales.add(locale.languageCode);

      _locale ??= locale;
    }
    return I10n._locales.contains(locale.languageCode);
  }

  @override
  Future<I10n> load(Locale locale) {
    _locale ??= locale;
    _reload = locale != _locale;
    _locale = locale;
    return I10n.load(locale);
  }

  @override
  bool shouldReload(I10nDelegate old) {
    bool reload = _reload;
    if (!reload) reload = this != old;
    _reload = false;
    return reload;
  }
}
