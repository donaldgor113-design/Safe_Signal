import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safe_signal/features/auth/presentation/providers/auth_provider.dart';
import 'package:safe_signal/features/auth/presentation/screens/login_screen.dart';
import 'package:safe_signal/features/auth/presentation/screens/register_screen.dart';
import 'package:safe_signal/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:safe_signal/features/contacts/presentation/screens/contacts_screen.dart';
import 'package:safe_signal/features/contacts/presentation/screens/add_contact_screen.dart';
import 'package:safe_signal/features/history/presentation/screens/history_screen.dart';
import 'package:safe_signal/features/medical_profile/presentation/screens/medical_profile_screen.dart';
import 'package:safe_signal/features/scenarios/presentation/screens/scenarios_screen.dart';
import 'package:safe_signal/features/sos/presentation/screens/home_screen.dart';
import 'package:safe_signal/features/sos/presentation/screens/sos_flow_screen.dart';
import 'package:safe_signal/shared/widgets/app_shell.dart';
import 'package:safe_signal/shared/widgets/onboarding_screen.dart';
import 'package:safe_signal/features/settings/presentation/screens/settings_screen.dart';
import 'package:safe_signal/shared/widgets/splash_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final isSplash = state.matchedLocation == '/splash';
      final isOnboarding = state.matchedLocation == '/onboarding';

      if (isSplash || isOnboarding) return null;

      if (!isLoggedIn && !isAuthRoute) return '/auth/login';
      if (isLoggedIn && isAuthRoute) return '/home';

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/auth/verify-email',
        builder: (context, state) => const VerifyEmailScreen(),
      ),
      GoRoute(
        path: '/sos-direct',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SosFlowScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MedicalProfileScreen(),
            ),
          ),
          GoRoute(
            path: '/contacts',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ContactsScreen(),
            ),
            routes: [
              GoRoute(
                path: 'add',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const AddContactScreen(),
              ),
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => AddContactScreen(
                  contactId: state.pathParameters['id'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/scenarios',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ScenariosScreen(),
            ),
          ),
          GoRoute(
            path: '/history',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HistoryScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
