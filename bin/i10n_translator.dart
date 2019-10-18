import 'package:i10n_translator/src/i10n_translator.dart';

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    I10nTranslator.logError(
        "Missing arguments (arguments are CSV file's name (mandatory) and target's file path)");
    return;
  }

  final translator = I10nTranslator();
  translator.generate(
      arguments.first, arguments.length == 2 ? arguments[1] : null);
}
