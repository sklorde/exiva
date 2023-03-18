import 'package:flutter/services.dart';

class TitleCaseInputFormatter extends TextInputFormatter {
  String textToTitleCase(String text) {
    if (text.length > 1) {
      return text[0].toUpperCase() + text.substring(1);
      /*or text[0].toUpperCase() + text.substring(1).toLowerCase(), if you want absolute title case*/
    } else if (text.length == 1) {
      return text[0].toUpperCase();
    }

    return '';
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String formattedText = newValue.text
        .split(' ')
        .map((element) => textToTitleCase(element))
        .toList()
        .join(' ');
    return TextEditingValue(
      text: formattedText,
      selection: newValue.selection,
    );
  }
}
