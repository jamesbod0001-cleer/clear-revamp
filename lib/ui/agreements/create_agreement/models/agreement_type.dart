enum AgreementType {
  send,
  request;

  bool get isSend => this == AgreementType.send;
  bool get isRequest => this == AgreementType.request;
}
