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
import 'dart:io' show Directory, File;
import 'dart:ui' as ui show TextHeightBehavior;

import 'package:csv/csv.dart' show CsvToListConverter;
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
import 'package:i10n_translator/src/i10n_translator.dart' show RESERVED_WORDS;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory, getExternalStorageDirectory;
import 'package:prefs/prefs.dart';
import 'package:universal_platform/universal_platform.dart'
    show UniversalPlatform;

/// Main I10n class to incorporate text translations into a mobile app.
class I10n {
  factory I10n() => _this ??= I10n._();
  I10n._();
  static I10n? _this;

  static final String kDefaultCSV = p.join('assets', 'i10n', 'i10n.csv');

  static String? _csvFile;
  static String? get csvFile {
    if (_csvFile == null || _csvFile!.isEmpty) {
      _csvFile = kDefaultCSV;
    }
    return _csvFile;
  }

  static Exception? _ex;
  static Locale? _locale;
  static Map<String?, String?>? _localizedValues;
  static bool _useKey = true;

  static Map<String, Map<String, String>>? _allValues;
  static List<String>? _locales;

  @Deprecated('Use the function, initAsync, instead of init')
  static Future<bool?> init({
    String? csv,
    Map<String, Map<String, String>>? map,
  }) =>
      I10n.initAsync(csv: csv, map: map);

  static Future<bool?> initAsync(
      {String? csv, Map<String, Map<String, String>>? map}) async {
    // Already been called
    if ((_allValues != null && _allValues!.isNotEmpty) || _I10n.file != null) {
      return false;
    }

    // Assign the csv file if not already assigned
    if (_csvFile == null && csv != null && csv.trim().isNotEmpty) {
      _csvFile = csv.trim();
      // If no path, set a path
      if (p.dirname(_csvFile!) == '.') {
        _csvFile = p.join('assets', 'i10n', p.basename(_csvFile!));
      } else if (_csvFile!.indexOf(p.separator) == 0) {
        _csvFile = _csvFile!.substring(1);
      }
      // If no file extension, add it.
      _csvFile = p.setExtension(_csvFile!, '.csv');
    }

    // Assign the map if not already assigned
    if (map != null && map.isNotEmpty) {
      _allValues ??= map;
    }

    bool? init = true;

    if (_allValues == null || _allValues!.isEmpty) {
      // Can't open a text file on the Web
      if (_csvFile != null &&
          _csvFile!.isNotEmpty &&
          !UniversalPlatform.isWeb) {
        // Open a csv file to place in entries.
        await _I10n.init(p.basename(_csvFile!));
      }
      try {
        // Create the 'default' csv file for the developer.
        if (I10n.csvFile == kDefaultCSV) {
          init = await _I10n.create(I10n.csvFile);
        }

        // Attempt to load the file
        if (init || UniversalPlatform.isWeb) {
          //
          init = await _I10n.load();

          final _locale = I10n.appLocale;

          if (_locale != null) {
            await I10n.load(_locale);
          }
        }
      } catch (ex) {
        init = false;
      }
    }

    if (_allValues != null) {
      _locales ??= _allValues!.keys.expand((e) => [e]).toList();
    }

    return init;
  }

  static List<Locale>? get supportedLocales => _locales == null
      ? null
      : _locales!.expand((e) {
          final List<String> locale = e.split('-');
          String languageCode;
          String? countryCode;
          if (locale.length == 2) {
            languageCode = locale.first;
            countryCode = locale.last;
          } else {
            languageCode = locale.first;
          }
          return [Locale(languageCode, countryCode)];
        }).toList();

  static Future<bool> dispose() => _I10n.dispose();

  /// Load the static Map object with the appropriate translations.
  static Future<I10n> load(Locale locale) async {
    _locale = locale;

//    await initializeDateFormatting(locale.languageCode, null);

    final String localString = locale.toLanguageTag();
    String? code;

    if (_allValues == null) {
      // No means to get the translations.
      _useKey = true;
      _locales ??= ['en-US'];
    } else {
      code = _allValues!.keys.firstWhere(
          (code) => code.toString() == localString,
          orElse: () => '');
      _useKey = code.isEmpty;
    }

    _localizedValues = _useKey ? {} : _allValues![code!];

    return Future.value(I10n());
  }

  static Locale? localeResolutionCallback(
      Locale? locale, Iterable<Locale>? supportedLocales) {
    //
    final _appLocale = appLocale;

    // Override the system's preferred locale with the app's preferred locale.
    if (_appLocale != null) {
      locale = _appLocale;
    }

    if (locale == null) {
      // Retrieve the 'first' locale in the supported locales.
      supportedLocales ??=
          I10n.supportedLocales!.take(I10n.supportedLocales!.length);
      if (supportedLocales.isNotEmpty) {
        // Use the first supported locale.
        locale = supportedLocales.first;
      }
    }
    return locale;
  }

  static Future<void> onSelectedItemChanged(int index) async {
    final locale = getLocale(index);
    if (locale != null) {
      await Prefs.setString('locale', locale.toLanguageTag());
    }
  }

  /// Return the preferred Locale
  static Locale? get appLocale => toLocale(Prefs.getString('locale', 'en-US'));

  static Locale? getLocale(int index) {
    Locale? locale;
    final localesList = I10n.supportedLocales;
    if (localesList != null && index >= 0) {
      locale = localesList[index];
    }
    return locale;
  }

  static Locale? toLocale(String? _locale) {
    Locale? locale;

    if (_locale != null && _locale.isNotEmpty) {
      //
      final localeCode = _locale.split('-');
      String languageCode;
      String? countryCode;
      if (localeCode.length == 2) {
        languageCode = localeCode.first;
        countryCode = localeCode.last;
      } else {
        languageCode = localeCode.first;
      }
      locale = Locale(languageCode, countryCode);
    }
    return locale;
  }

  /// Convert a Text object to one with a translation.
  static Text of(
    Text? text, {
    Key? key,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextAlign? textAlign,
    TextDirection? textDirection,
    Locale? locale,
    bool? softWrap,
    TextOverflow? overflow,
    double? textScaleFactor,
    int? maxLines,
    String? semanticsLabel,
    TextWidthBasis? textWidthBasis,
  }) =>
      t(
        text?.data,
        key: key ?? text?.key,
        style: style ?? text?.style,
        strutStyle: strutStyle ?? text?.strutStyle,
        textAlign: textAlign ?? text?.textAlign,
        textDirection: textDirection ?? text?.textDirection,
        locale: locale ?? text?.locale,
        softWrap: softWrap ?? text?.softWrap,
        overflow: overflow ?? text?.overflow,
        textScaleFactor: textScaleFactor ?? text?.textScaleFactor,
        maxLines: maxLines ?? text?.maxLines,
        semanticsLabel: semanticsLabel ?? text?.semanticsLabel,
        textWidthBasis: textWidthBasis ?? text?.textWidthBasis,
      );

  /// Supply a Text object for the translation.
  static Text t(
    String? data, {
    Key? key,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextAlign? textAlign,
    TextDirection? textDirection,
    Locale? locale,
    bool? softWrap,
    TextOverflow? overflow,
    double? textScaleFactor,
    int? maxLines,
    String? semanticsLabel,
    TextWidthBasis? textWidthBasis,
    ui.TextHeightBehavior? textHeightBehavior,
  }) =>
      Text(
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
        textHeightBehavior: textHeightBehavior,
      );

  /// Translate the String
  static String s(String? key) {
    /// While developing, return 'null' when appropriate
    /// Add key words to a file if not yet found there.
    /// assert is removed in production.
    assert(() {
      if (key == null) {
        key = 'null';
      } else {
        // Remove any leading and trailing spaces.
        key = key!.trim();
      }

      if (_I10n.file != null &&
          _useKey &&
          (_allValues == null || _allValues!.isEmpty) &&
          _localizedValues != null &&
          _localizedValues![key] == null) {
        _localizedValues!.addAll({key: key});
        _I10n.add(key);
      }
      return true;
    }());

    /// If not translation, provide the key itself instead.
    return _useKey ? key ?? '' : _localizedValues![key] ?? key ?? '';
  }

  /// The current Locale object.
  static Locale? get locale => _locale;

  Object get message => _ex?.toString() ?? '';

  static bool inError() => _ex != null;

  static Exception? getError() {
    final e = _ex;
    _ex = null;
    return e;
  }
}

typedef fileFunc = List<String> Function(File file);

typedef collectFunc = bool Function(
    List<Map<String, String>> maps, List<String> supportedLanguages);

// ignore: avoid_classes_with_only_static_members
class _I10n {
  static List<String>? lines;
  static File? file;
  static String contents = '';

  static Future<bool> init(String? csvFile) async {
    // Already been called
    if (file != null) {
      return true;
    }
    // Process the parameter
    if (csvFile == null || csvFile.trim().isEmpty) {
      return false;
    }

    String path;
    try {
      Directory? directory;
      if (UniversalPlatform.isIOS) {
        //
        directory = await getApplicationDocumentsDirectory();
      } else if (UniversalPlatform.isAndroid) {
        //
        directory = await getExternalStorageDirectory();
      }
      path = directory!.path; //+ p.separator;
    } catch (ex) {
      path = '';
    }

    if (path.isEmpty) {
      return false;
    }

    path = p.join(path, csvFile);

    file = File(path);

    bool init = true;

    if (!file!.existsSync()) {
      try {
        file!.createSync(recursive: true);
      } catch (ex) {
        init = false;
      }
    } else {
      try {
        contents = await file!.readAsString();
      } catch (ex) {
        contents = '';
        init = false;
      }
    }
    return init;
  }

  static Future<bool> dispose() async {
    bool write = contents.trim().isNotEmpty; // ?? false;
    if (!write) {
      return false;
    }
    try {
      await file?.writeAsString(contents, flush: true);
      write = true;
    } catch (ex) {
      write = false;
    }
    return write;
  }

  static Future<bool> create(String? csvFile) async {
    // Process the parameter
    if (csvFile == null || csvFile.trim().isEmpty || UniversalPlatform.isWeb) {
      return false;
    }

    String path;
    try {
      Directory? directory;
      if (UniversalPlatform.isIOS) {
        //
        directory = await getApplicationDocumentsDirectory();
      } else if (UniversalPlatform.isAndroid) {
        //
        directory = await getExternalStorageDirectory();
      }
      path = directory!.path;
    } catch (ex) {
      path = '';
    }

    if (path.isEmpty) {
      return false;
    }

    path = p.join(path, csvFile);

    final file = File(path);

    bool created = true;

    if (!file.existsSync()) {
      try {
        file.createSync(recursive: true);
      } catch (ex) {
        created = false;
      }
    }
    return created;
  }

  static Future<bool> add(String? word) async {
    if (word == null || word.trim().isEmpty) {
      return false;
    }
    contents += '${word.trim()},\r\n';
    return true;
  }

  static Future<bool?> load() async {
    String content;
    try {
      content = await rootBundle.loadString(I10n.csvFile!);
      lines = content.split('\r\n');
    } catch (ex) {
      lines = [];
    }

    if (lines!.isEmpty) {
      return false;
    }

    final bool? load = generate(() {
      // Remove any blank lines.
      lines!.removeWhere((line) => line.isEmpty);

      if (lines!.isEmpty) {
        logError('File is empty:\n ${I10n._csvFile}');
        return lines;
      }
      return lines;
    }, (List<Map<String, String>>? maps, List<String> languages) {
      I10n._locales = languages;

      I10n._allValues?.clear();

      I10n._allValues = {};

      Map<String, String>? map;
      String lang;

      // Assume the first code is the 'default' language. The rest are the translations.
      final List<String> supportedLanguages =
          languages.sublist(1, languages.length);

      for (var index = 0; index < supportedLanguages.length; index++) {
        lang = supportedLanguages[index];

        map = maps![index];

        // ignore: unnecessary_null_comparison
        if (map == null) {
          break;
        }

        I10n._allValues?.addAll({lang: map});
      }
      return true;
    });

    return load;
  }

  static bool? generate(Function fileFunc, Function collectFunc) {
    final List<String> lines = fileFunc();

    if (lines.isEmpty) {
      return false;
    }

    // Get the language codes.
    final List<String> languages = getLineOfWords(lines.first);

    final Iterable<String> invalid = languages.where((code) {
      final length = code.trim().length;
      return length != 2 && length != 3 && length != 5;
    });

    if (invalid.isNotEmpty) {
      logError('Not valid language code(s):\n $invalid');
      return false;
    }

    // Assume the first code is the 'default' language. The rest are the translations.
    final List<String> supportedLanguages =
        languages.sublist(1, languages.length);

    final List<Map<String, String>> maps = [];

    // Add a Map object the List with every Language.
    // ignore: avoid_function_literals_in_foreach_calls
    supportedLanguages.forEach((_) => maps.add({}));

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
            '$key is a reserved keyword and cannot be used as key (line ${linesIndex + 1})');
        continue;
      }

      // Assume the rest of the words are the translations.
      words = lineOfWords.sublist(1, lineOfWords.length);

      if (words.length != supportedLanguages.length) {
        logError(
            'The line number ${linesIndex + 1} seems malformatted (${words.length} words for ${supportedLanguages.length} columns)');
      }

      for (var wordIndex = 0; wordIndex < words.length; wordIndex++) {
        noWord = words[wordIndex].isEmpty;
        maps[wordIndex][key] = noWord ? key : words[wordIndex];
        if (noWord) {
          logError(
              'The line number ${linesIndex + 1} had no word and so key was used: $key');
        }
      }
    }
    // Collect the values from the maps
    return collectFunc(maps, languages);
  }

  static List<String> getLineOfWords(String line) => const CsvToListConverter()
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

  // ignore: avoid_print
  static void logError(String text) => print('[I10n ERROR] $text\r\n');
}

/// The I10n package's locale delegate
///
class I10nDelegate extends LocalizationsDelegate<I10n> {
  // No need for more than one instance.
  factory I10nDelegate() => _this ??= I10nDelegate._();
  I10nDelegate._();
  static I10nDelegate? _this;

  static Locale? _locale;
  static bool _reload = false;

  @override
  bool isSupported(Locale locale) {
    final _locales = I10n._locales;
    // If 'I10n._locale == null' then you're loading the app's locale.
    if (I10n._locale == null) {
      I10n._locale = locale;

      if (_locales == null || _locales.isEmpty) {
        I10n._locales = [locale.toLanguageTag()];
      } else if (!_locales.contains(locale.toLanguageTag())) {
        _locales.add(locale.languageCode);
        I10n._locales = _locales;
      }
      _locale ??= locale;
    }
    return _locales?.contains(locale.toLanguageTag()) ?? false;
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
    if (!reload) {
      reload = this != old;
    }
    _reload = false;
    return reload;
  }
}
