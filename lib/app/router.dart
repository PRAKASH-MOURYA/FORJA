import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';

import '../features/splash/splash_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/onboarding/quiz_screen.dart';
import '../features/exercise/exercise_library_screen.dart';
import '../features/today/today_screen.dart';
import '../features/history/history_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/workout/workout_screen.dart';
import '../shared/models/exercise.dart';
import '../features/workout/complete_screen.dart';
import '../features/auth/auth_screen.dart';
import '../features/challenges/challenge_screen.dart';
import '../features/challenges/challenge_invite_screen.dart';
import '../features/splits/split_builder_screen.dart';
import '../shared/widgets/bottom_nav.dart';
import '../shared/providers/auth_provider.dart';
import '../shared/services/challenge_service.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  // Listen to both auth and guest state to trigger redirects
  final authState = ref.watch(authStateProvider).value;
  final isAuthenticated = authState?.session?.user != null;
  final isGuest = ref.watch(isGuestProvider);
  final profile = ref.watch(userProfileProvider);
  final isOnboarded = profile?.onboardingComplete ?? false;

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final isSplash = loc == '/splash';
      final isAuthRoute = loc == '/auth';
      final isOnboardingRoute = loc == '/onboarding' || loc == '/quiz';

      // Splash always allowed through
      if (isSplash) return null;

      // 1. Not authenticated and not guest → require auth
      if (!isAuthenticated && !isGuest) {
        return isAuthRoute ? null : '/auth';
      }

      // 2. Authenticated/guest but onboarding not complete → require onboarding
      if (!isOnboarded) {
        return isOnboardingRoute ? null : '/onboarding';
      }

      // 3. Already authenticated/onboarded, on an auth or onboarding route → skip to today
      if (isAuthRoute || isOnboardingRoute) {
        return '/today';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth',
        pageBuilder: (context, state) => _fadeSlideTransition(
          state, const AuthScreen()),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/quiz',
        builder: (context, state) => const QuizScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => ScaffoldWithBottomNav(child: child),
        routes: [
          GoRoute(
            path: '/today',
            pageBuilder: (context, state) =>
                _fadeSlideTransition(state, const TodayScreen()),
          ),
          GoRoute(
            path: '/history',
            pageBuilder: (context, state) =>
                _fadeSlideTransition(state, const HistoryScreen()),
          ),
          GoRoute(
            path: '/exercises',
            pageBuilder: (context, state) =>
                _fadeSlideTransition(state, const ExerciseLibraryScreen()),
          ),
          GoRoute(
            path: '/progress',
            pageBuilder: (context, state) =>
                _fadeSlideTransition(state, const ProgressScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                _fadeSlideTransition(state, const ProfileScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/workout',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final exercises =
              extra?['exercises'] as List<Exercise>? ?? const [];
          final dayName = extra?['dayName'] as String? ?? 'Workout';
          return WorkoutScreen(exercises: exercises, dayName: dayName);
        },
      ),
      GoRoute(
        path: '/workout/complete',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CompleteScreen(),
      ),
      GoRoute(
        path: '/challenges',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ChallengeScreen(),
      ),
      GoRoute(
        path: '/challenge/join/:code',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ChallengeInviteScreen(
          inviteCode: state.pathParameters['code']!,
        ),
      ),
      GoRoute(
        path: '/split-builder',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SplitBuilderScreen(),
      ),
    ],
  );
});

CustomTransitionPage<void> _fadeSlideTransition(
    GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
            parent: animation, curve: Curves.easeInOut),
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
              parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        ),
      );
    },
  );
}

class ScaffoldWithBottomNav extends ConsumerStatefulWidget {
  final Widget child;
  const ScaffoldWithBottomNav({super.key, required this.child});

  @override
  ConsumerState<ScaffoldWithBottomNav> createState() =>
      _ScaffoldWithBottomNavState();
}

class _ScaffoldWithBottomNavState extends ConsumerState<ScaffoldWithBottomNav> {
  int _currentIndex = 0;
  StreamSubscription<Uri>? _deepLinkSub;

  static const _tabs = ['/today', '/history', '/exercises', '/progress', '/profile'];

  @override
  void initState() {
    super.initState();
    _deepLinkSub = AppLinks().uriLinkStream.listen((uri) {
      if (!mounted) return;
      try {
        final inviteCode = ChallengeService.parseInviteCode(uri.toString());
        context.push('/challenge/join/$inviteCode');
      } catch (_) {
        // Ignore non-challenge links.
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: ForjaBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          context.go(_tabs[index]);
        },
      ),
    );
  }

  @override
  void dispose() {
    _deepLinkSub?.cancel();
    super.dispose();
  }
}
