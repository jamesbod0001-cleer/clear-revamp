import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DecimalThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 1. If empty, return empty
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // 2. Allow only digits and one decimal point
    // We strip everything except 0-9 and .
    String cleanText = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');

    // 3. Handle multiple decimal points (only keep the first one)
    if (cleanText.contains('.')) {
      List<String> parts = cleanText.split('.');
      cleanText = '${parts[0]}.${parts.sublist(1).join('')}';
    }

    // 4. If the user just typed the dot (e.g., "2,000."),
    // we return it as is to allow them to type the decimals.
    if (cleanText.endsWith('.')) {
      return newValue.copyWith(
        text: cleanText,
        selection: TextSelection.collapsed(offset: cleanText.length),
      );
    }

    // 5. Parse and Format
    final double? value = double.tryParse(cleanText);
    if (value == null) return oldValue;

    final formatter = NumberFormat.decimalPattern();

    // Split to handle fractional part separately to avoid rounding issues while typing
    List<String> parts = cleanText.split('.');
    String formattedInteger = formatter.format(int.parse(parts[0]));

    String finalString = parts.length > 1
        ? '$formattedInteger.${parts[1]}'
        : formattedInteger;

    return newValue.copyWith(
      text: finalString,
      selection: TextSelection.collapsed(offset: finalString.length),
    );
  }
}
