class AppConfig {
  static const String environment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: bool.fromEnvironment('dart.vm.product') ? 'local' : 'main',
  );

  static String get baseUrl {
    switch (environment) {
      case 'main':
        return 'https://app.cleerpayments.com';
      case 'develop':
      case 'local':
      default:
        return 'https://staging.cleerpayments.com';
    }
  }
}