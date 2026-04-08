enum AppEnvironment { dev, staging, prod }

class AppConfig {
  static AppEnvironment environment = AppEnvironment.dev;

  static String get baseUrl {
    switch (environment) {
      case AppEnvironment.dev:
        return 'https://farmers_market.test/api';
      case AppEnvironment.staging:
        return '';
      case AppEnvironment.prod:
        return '';
    }
  }

  static bool get isDebug => environment == AppEnvironment.dev;
}