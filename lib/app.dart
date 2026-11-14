/// Root widget: MaterialApp.router, theme, routes and MultiProvider.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'core/routes.dart';
import 'providers/auth_provider.dart';
import 'providers/lead_provider.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<StorageService>.value(value: StorageService.instance),
        Provider<ApiService>(create: (_) => ApiService()),
        ChangeNotifierProvider<AuthProvider>(
          create: (ctx) => AuthProvider(ctx.read<StorageService>()),
        ),
        ChangeNotifierProvider<LeadProvider>(
          create: (ctx) =>
              LeadProvider(ctx.read<StorageService>(), ctx.read<ApiService>()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Lead Tracker',
        debugShowCheckedModeBanner: false,
        theme: appTheme(),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
