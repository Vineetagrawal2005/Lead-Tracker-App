import 'package:flutter/material.dart';

import 'app.dart';
import 'services/storage_service.dart';

void main() async {
  // Initialize Hive and SharedPreferences before running the app so providers
  // and screens can read/write local storage immediately.
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.instance.init();
  runApp(const App());
}
