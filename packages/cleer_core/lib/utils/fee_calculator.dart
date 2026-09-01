/// Utility class for calculating transaction and platform fees.
abstract class FeeCalculator {
  /// Standard Flutterwave payment processing fee rate (2% flat).
  static const double flutterwaveFeeRate = 0.02;

  /// Cleer platform service fee rate (0% for now, configurable for future charges).
  static const double cleerFeeRate = 0.0;

  /// Calculates the Cleer platform fee based on the base agreement amount.
  static double calculateCleerFee(double agreementAmount) {
    if (agreementAmount <= 0) return 0.0;
    return agreementAmount * cleerFeeRate;
  }

  /// Calculates the requested charge base sent to Flutterwave (Agreement Amount + Cleer Fee).
  static double calculateChargeAmount(double agreementAmount) {
    if (agreementAmount <= 0) return 0.0;
    return agreementAmount + calculateCleerFee(agreementAmount);
  }

  /// Calculates the Flutterwave gateway processing fee (2% of chargeAmount).
  static double calculateGatewayFee(double chargeAmount) {
    if (chargeAmount <= 0) return 0.0;
    return chargeAmount * flutterwaveFeeRate;
  }

  /// Calculates the total combined fee (Cleer Fee + Gateway Fee).
  static double calculateTotalFee(double agreementAmount) {
    if (agreementAmount <= 0) return 0.0;
    final cleerFee = calculateCleerFee(agreementAmount);
    final chargeAmount = agreementAmount + cleerFee;
    return cleerFee + calculateGatewayFee(chargeAmount);
  }
}
