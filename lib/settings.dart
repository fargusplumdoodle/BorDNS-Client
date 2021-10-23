import 'dart:io';

import 'package:flutter/foundation.dart';

enum Environments { desktop, mobile }

class Settings {
  static Environments env = determineEnvironments();

  static const String apiHost = String.fromEnvironment("API_HOST");
  // TODO: STORE THESE LOCALLY
  static const String username = String.fromEnvironment("USERNAME");
  static const String password = String.fromEnvironment("PASSWORD");

  static Environments determineEnvironments() {
    const env = String.fromEnvironment("ENV");
    switch (env) {
      case "mobile":
        {
          return Environments.mobile;
        }
      case "desktop":
        {
          return Environments.desktop;
        }
    }
    final desktop =
        (Platform.isLinux || kIsWeb || Platform.isWindows || Platform.isMacOS);
    return desktop ? Environments.desktop : Environments.mobile;
  }
}

final routes = {
  "DASHBOARD": "digg",
  "TRANSACTIONS": "ah",
  "TRANSFER FUNDS": "donmatt",
  "ADD TRANSACTION": "ey",
  "TAGS": "no",
  "BUDGET PERCENTAGES": "ah",
};
