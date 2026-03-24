import 'package:cleer/domain/models/agreement/agreement.dart';
import 'package:flutter/material.dart';

class AgreementDetailsScreen extends StatelessWidget {
  const AgreementDetailsScreen({super.key, required this.agreementId, this.initialAgreement});

  final String agreementId;
  final Agreement? initialAgreement;

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
