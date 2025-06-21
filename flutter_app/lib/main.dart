import 'package:flutter/material.dart';
import 'package:flutter_app/screens/a.dart';
import 'package:flutter_app/screens/b.dart';
import 'package:flutter_app/screens/c.dart';
import 'package:flutter_app/screens/d.dart';
import 'package:flutter_app/screens/test/test.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Test(),
    );
  }
}