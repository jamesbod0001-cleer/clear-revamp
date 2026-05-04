import 'package:flutter/services.dart';

class CardExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var newText = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Handle the month limit
    if (newText.isNotEmpty && (int.tryParse(newText[0]) ?? 0) > 1) {
      newText = '0$newText';
    }

    var buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(newText[i]);
      if (i >= 3) break; // Limit to MM/YY
    }

    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}
