import 'package:flutter/material.dart';
import '../widgets/navbar.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const NavBar(title: Text(""), body: Text("Bienvenido usuario"));
  }
}
