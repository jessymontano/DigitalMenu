import 'package:flutter/material.dart';

import 'src/pages/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DigitalMenu',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 212, 10, 8)),
        textTheme: TextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
          backgroundColor: Color.fromARGB(255, 212, 10, 8),
        )),
        useMaterial3: true,
      ),
      home: const Login(),
    );
  }
}
