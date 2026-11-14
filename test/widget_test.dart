import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:lead_tracker/core/theme.dart';
import 'package:lead_tracker/providers/auth_provider.dart';
import 'package:lead_tracker/providers/lead_provider.dart';
import 'package:lead_tracker/screens/auth/login_screen.dart';
import 'package:lead_tracker/services/api_service.dart';
import 'package:lead_tracker/services/storage_service.dart';

void main() {
  testWidgets('Login form shows validation errors for empty input', (
    WidgetTester tester,
  ) async {
    // Build just the login screen with minimal providers. Storage is not
    // initialized here; tapping Login won't succeed but validation will run.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<StorageService>.value(value: StorageService.instance),
          Provider<ApiService>(create: (_) => ApiService()),
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider(StorageService.instance),
          ),
          ChangeNotifierProvider<LeadProvider>(
            create: (_) => LeadProvider(StorageService.instance, ApiService()),
          ),
        ],
        child: MaterialApp(theme: appTheme(), home: const LoginScreen()),
      ),
    );

    // Tap login without entering anything.
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
  });
}
