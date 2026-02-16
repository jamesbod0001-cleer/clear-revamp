class ReferenceGenerator {
  static String generate(String agreementId) {
    final cleanId = agreementId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

    final idPart = cleanId.length > 8 ? cleanId.substring(0, 8) : cleanId;

    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    final timePart = timestamp.substring(timestamp.length - 8);

    return '$idPart$timePart';
  }
}