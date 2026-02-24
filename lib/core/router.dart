import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/perspectives/perspectives_screen.dart';
import '../screens/pricing/pricing_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/event_detail/event_detail_screen.dart';
import '../screens/saved/saved_screen.dart';
import '../models/historical_event.dart';
import '../services/auth_service.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) async {
      final auth = context.read<AuthService>();
      final isAuth = auth.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/splash' ||
          state.matchedLocation == '/onboarding';

      if (state.matchedLocation == '/splash') return null;
      if (!isAuth && !isAuthRoute) return '/login';
      if (isAuth && (state.matchedLocation == '/login' || state.matchedLocation == '/signup')) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/event',
        builder: (context, state) {
          final event = state.extra as HistoricalEvent;
          return EventDetailScreen(event: event);
        },
      ),
      GoRoute(
        path: '/perspectives',
        builder: (context, state) {
          final event = state.extra as HistoricalEvent;
          return PerspectivesScreen(event: event);
        },
      ),
      GoRoute(path: '/pricing', builder: (context, state) => const PricingScreen()),
      GoRoute(path: '/saved', builder: (context, state) => const SavedScreen()),
    ],
  );
}

/// Call on splash to determine first route
Future<String> getInitialRoute(AuthService auth) async {
  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool('onboarding_done') ?? false;
  if (!onboardingDone) return '/onboarding';
  if (auth.isAuthenticated) return '/home';
  return '/login';
}
