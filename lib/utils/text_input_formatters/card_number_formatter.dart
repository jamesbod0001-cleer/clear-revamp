import 'package:flutter/services.dart';

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll(RegExp(r'\D'), '');
    var buffer = StringBuffer();

    // Detect if it's an Amex to change formatting logic
    final isAmex = text.startsWith('34') || text.startsWith('37');

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      int nonZeroIndex = i + 1;

      if (isAmex) {
        // Amex: Space after 4th and 10th character
        if ((nonZeroIndex == 4 || nonZeroIndex == 10) && nonZeroIndex != text.length) {
          buffer.write(' ');
        }
      } else {
        // Standard: Space every 4 characters
        if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
          buffer.write(' ');
        }
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}