import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:carpe_diem/ui/screens/home_screen.dart';
import 'package:carpe_diem/ui/screens/projects_screen.dart';
import 'package:carpe_diem/ui/shell/app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(child: HomeScreen()),
        ),
        GoRoute(
          path: '/projects',
          pageBuilder: (context, state) => const NoTransitionPage(child: ProjectsScreen()),
        ),
      ],
    ),
  ],
);
