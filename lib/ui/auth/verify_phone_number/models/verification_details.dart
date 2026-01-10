import 'package:cleer/utils/constants.dart';

class VerificationDetails {
  final String username;
  final String destination;
  final String deliveryMedium;

  const VerificationDetails({
    required this.username,
    required this.destination,
    required this.deliveryMedium,
  });

  factory VerificationDetails.empty() {
    return const VerificationDetails(
      username: kEmpty,
      destination: kEmpty,
      deliveryMedium: kEmpty,
    );
  }
}
