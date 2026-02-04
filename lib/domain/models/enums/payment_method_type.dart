enum PaymentMethodType {
  card,
  opay;

  String get snakeCase {
    return name.replaceAllMapped(RegExp(r'([A-Z])'), (match) {
      return '_${match.group(0)!.toLowerCase()}';
    }).toLowerCase();
  }
}