import 'package:flutter/material.dart';
import 'package:flutter_app/screens/ore2_profile.dart';
import 'package:flutter_app/screens/test/test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_app/screens/home.dart';
import 'package:flutter_app/screens/a.dart';
import 'package:flutter_app/screens/b.dart';
import 'package:flutter_app/screens/c.dart';
import 'package:flutter_app/screens/library.dart';
import 'package:flutter_app/widgets/shell.dart';
import 'package:flutter_app/screens/complex_form.dart';



final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => Shell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => NoTransitionPage(child: Home()),
        ),
        GoRoute(
          path: '/journal',
          pageBuilder: (context, state) => NoTransitionPage(child: A()),
        ),
        GoRoute(
          path: '/cafe',
          pageBuilder: (context, state) => NoTransitionPage(child: B()),
        ),
        GoRoute(
          path: '/library',
          pageBuilder: (context, state) => NoTransitionPage(child: Library()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => NoTransitionPage(child: ProfileScreen()),
        ),
        GoRoute(
          path: '/comp',
          pageBuilder: (context, state) => NoTransitionPage(child: ComplexForm(
            basicData: {},
            emotionData: {},
          )),
        ),
      ],
    ),
  ],
);