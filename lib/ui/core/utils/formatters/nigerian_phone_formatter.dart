import 'package:flutter/services.dart';

class NigerianPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // 1. Remove all spaces and non-numeric characters
    String text = newValue.text.replaceAll(RegExp(r'\D'), '');

    // 2. Handle the leading '0'
    // If they type 080... it becomes 80...
    if (text.startsWith('0')) {
      text = text.substring(1);
    }

    // 3. Limit to 10 digits (Nigerian mobile length without the leading 0)
    if (text.length > 10) {
      text = text.substring(0, 10);
    }

    // 4. Build the display string with spaces: 000 000 0000
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i == 2 || i == 5) && i != text.length - 1) {
        buffer.write(' ');
      }
    }

    final String formattedText = buffer.toString();

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}