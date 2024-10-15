import 'package:flutter/material.dart';
import 'src/pages/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://kgxonqwulbraeezxplxw.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtneG9ucXd1bGJyYWVlenhwbHh3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjY2MTkyODIsImV4cCI6MjA0MjE5NTI4Mn0.2YDiyaA8Y4aJ8JWnyye3suLtajijA3znF7onyYiNKfI',
  );

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
          primarySwatch: Colors.red,
          highlightColor: Colors.red,
          primaryColor: Colors.red,
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 212, 10, 8),
              brightness: Brightness.light),
          useMaterial3: true,
          textTheme: const TextTheme(
              displayLarge: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
          ))),
      home: const Login(),
    );
  }
}
