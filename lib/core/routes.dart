import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants.dart';
import '../models/lead_model.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/main_shell.dart';
import '../screens/leads/lead_details_screen.dart';
import '../screens/leads/add_edit_lead_screen.dart';

/// GoRouter configuration for the app.
///
/// Uses [go_router] as requested. Navigation flow:
/// Splash -> Login/Signup -> MainShell (tabs: Dashboard, Leads, Profile).
/// Lead details and add/edit are pushed on top.
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: kRouteSplash,
    routes: <RouteBase>[
      GoRoute(
        path: kRouteSplash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: kRouteLogin,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: kRouteSignup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: kRouteMainShell,
        name: 'main',
        builder: (context, state) => const MainShell(),
      ),
      GoRoute(
        path: '$kRouteLeadDetails/:id',
        name: 'leadDetails',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final heroTag = state.extra as String?;
          return LeadDetailsScreen(leadId: id, heroTag: heroTag);
        },
      ),
      GoRoute(
        path: kRouteAddEditLead,
        name: 'addEditLead',
        builder: (context, state) {
          final lead = state.extra as LeadModel?;
          return AddEditLeadScreen(lead: lead);
        },
      ),
    ],
    errorBuilder: (context, state) => const SplashScreen(),
  );
}

// Keep old name compatibility for any imports expecting AppRoutes if needed.
// Not used with go_router but avoids breakage.
abstract class AppRoutes {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => const SplashScreen());
  }
}
