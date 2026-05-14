enum AlertSeverity { critical, warning, info }

sealed class ActionAlert {
  final AlertSeverity severity;
  final int priority;

  ActionAlert({required this.severity, required this.priority});
}

class ActiveDisputesAlert extends ActionAlert {
  final int count;

  ActiveDisputesAlert({
    required this.count,
    required super.severity,
    required super.priority,
  });
}

class VerifyNinAlert extends ActionAlert {
  VerifyNinAlert({required super.severity, required super.priority});
}

class AddEmailAlert extends ActionAlert {
  AddEmailAlert({required super.severity, required super.priority});
}

class VerifyEmailAlert extends ActionAlert {
  VerifyEmailAlert({required super.severity, required super.priority});
}
