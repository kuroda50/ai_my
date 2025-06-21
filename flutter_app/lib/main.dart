import 'package:flutter/material.dart';
import 'package:flutter_app/config/router.dart';
import 'package:flutter_app/screens/a.dart';
import 'package:flutter_app/screens/b.dart';
import 'package:flutter_app/screens/c.dart';
import 'package:flutter_app/screens/d.dart';
import 'package:flutter_app/screens/test/test.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig:router,
      debugShowCheckedModeBanner: false,
      title: 'My App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
    );
  }
}