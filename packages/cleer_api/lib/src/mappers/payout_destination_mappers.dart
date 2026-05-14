import 'package:cleer_api/src/models/ModelProvider.dart' as amplify_model;
import 'package:cleer_api/src/mappers/user_mappers.dart';
import 'package:cleer_core/models/payout_destination/payout_destination.dart'
    as domain;

/// Extensions on the Amplify PayoutDestination model to convert it to the Domain Task entity.
extension PayoutDestinationToDomainMapper on amplify_model.PayoutDestination {
  domain.PayoutDestination toDomain() {
    return domain.PayoutDestination(
      accountNumber: accountNumber,
      bankCode: bankCode,
      currency: currency,
      bankName: bankName,
      accountName: accountName,
      user: user?.toDomain(),
      createdAt: createdAt?.getDateTimeInUtc(),
    );
  }
}

/// Extensions on the Domain PayoutDestination entity to convert it back to the Amplify model for mutations.
extension PayoutDestinationToAmplifyMapper on domain.PayoutDestination {
  amplify_model.PayoutDestination toAmplify() {
    return amplify_model.PayoutDestination(
      accountNumber: accountNumber,
      bankCode: bankCode,
      currency: currency,
      bankName: bankName,
      accountName: accountName,
      user: user?.toAmplify(),
    );
  }
}
