import 'package:cleer/domain/models/agreement/agreement_enums.dart';

enum AgreementType {
  send,
  request;

  bool get isSend => this == AgreementType.send;
  bool get isRequest => this == AgreementType.request;

  InitiatorRole get initiatorRole {
    switch (this) {
      case AgreementType.send:
        return InitiatorRole.sender;
      case AgreementType.request:
        return InitiatorRole.recipient;
    }
  }
}
