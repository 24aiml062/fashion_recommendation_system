import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/onboarding/quiz_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/discover/discover_screen.dart';
import '../screens/stylist/chat_screen.dart';
import '../screens/wardrobe/wardrobe_screen.dart';
import '../screens/wardrobe/add_item_screen.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/shell_screen.dart';

class AppRouter {
  static GoRouter router(AuthProvider auth) => GoRouter(
        initialLocation: '/splash',
        refreshListenable: auth,
        redirect: (context, state) {
          final isLoggedIn = auth.isLoggedIn;
          final isOnboarded = auth.isOnboarded;
          final path = state.uri.toString();

          if (path == '/splash') return null;

          if (!isLoggedIn) {
            if (path.startsWith('/auth')) return null;
            return '/auth/login';
          }

          if (!isOnboarded && path != '/onboarding') return '/onboarding';

          if (path.startsWith('/auth')) return '/home';

          return null;
        },
        routes: [
          GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
          GoRoute(path: '/auth/login', builder: (_, __) => const LoginScreen()),
          GoRoute(path: '/auth/signup', builder: (_, __) => const SignupScreen()),
          GoRoute(path: '/onboarding', builder: (_, __) => const QuizScreen()),
          ShellRoute(
            builder: (context, state, child) => ShellScreen(child: child),
            routes: [
              GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
              GoRoute(path: '/discover', builder: (_, __) => const DiscoverScreen()),
              GoRoute(path: '/stylist', builder: (_, __) => const ChatScreen()),
              GoRoute(
                path: '/wardrobe',
                builder: (_, __) => const WardrobeScreen(),
                routes: [
                  GoRoute(path: 'add', builder: (_, __) => const AddItemScreen()),
                ],
              ),
              GoRoute(path: '/calendar', builder: (_, __) => const CalendarScreen()),
              GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
            ],
          ),
        ],
      );
}
