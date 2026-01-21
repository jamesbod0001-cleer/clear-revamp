import 'package:cleer/domain/models/enums/app_connection_status.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

extension AppConnectionStatusToDomain on InternetStatus {
  AppConnectionStatus toDomain() {
    switch (this) {
      case InternetStatus.connected:
        return AppConnectionStatus.connected;
      case InternetStatus.disconnected:
        return AppConnectionStatus.disconnected;
    }
  }
}
