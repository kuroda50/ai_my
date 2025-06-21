import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/screens/a.dart';
import 'package:flutter_app/screens/b.dart';
import 'package:flutter_app/screens/c.dart';
import 'package:flutter_app/widgets/shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/journal',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => Shell(child: child),
      routes: [
        GoRoute(
          path: '/journal',
          pageBuilder: (context, state) => NoTransitionPage(child: A()),
        ),
        GoRoute(
          path: '/cafe',
          pageBuilder: (context, state) => NoTransitionPage(child: B()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => NoTransitionPage(child: C()),
        ),
      ],
    ),
  ],
);