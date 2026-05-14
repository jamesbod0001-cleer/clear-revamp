enum CardNetwork {
  mastercard,
  visa,
  americanExpress,
  discover,
  verve,
  afrigo,
  unknown;

  static CardNetwork fromNumber(String number) {
    final cleanNumber = number.replaceAll(RegExp(r'\D'), '');

    if (cleanNumber.isEmpty) return CardNetwork.unknown;

    if (RegExp(r'^4').hasMatch(cleanNumber)) return CardNetwork.visa;
    if (RegExp(r'^5[1-5]').hasMatch(cleanNumber)) return CardNetwork.mastercard;
    if (RegExp(r'^3[47]').hasMatch(cleanNumber)) {
      return CardNetwork.americanExpress;
    }
    if (RegExp(r'^6(?:011|5)').hasMatch(cleanNumber)) {
      return CardNetwork.discover;
    }

    // Verve (Nigerian standard: often starts with 5061, 5078, 6500)
    if (RegExp(r'^(506[01]|507[89]|6500)').hasMatch(cleanNumber)) {
      return CardNetwork.verve;
    }
    // Afrigo (Pattern: starts with 9)
    if (RegExp(r'^9').hasMatch(cleanNumber)) return CardNetwork.afrigo;

    return CardNetwork.unknown;
  }
}
