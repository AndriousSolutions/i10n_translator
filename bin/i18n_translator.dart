import 'package:i18n_translator/src/i18n_translator.dart';

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    I18nTranslator.logError(
        "Missing arguments (arguments are CSV file's name (mandatory) and target's file path)");
    return;
  }

  final translator = I18nTranslator();
  translator.generate(
      arguments.first, arguments.length == 2 ? arguments[1] : null);
}
