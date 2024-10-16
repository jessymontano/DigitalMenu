import 'package:digital_menu/src/widgets/platillos.dart';
import 'package:flutter/material.dart';
import '../widgets/navbar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  List<Widget> _homeOptions = [Platillos(), Text("ordenes")];
  @override
  Widget build(BuildContext context) {
    return NavBar(
        title: const Text(""),
        body: Column(children: [
          Expanded(
            child: Container(
                padding: const EdgeInsets.all(20),
                child: IndexedStack(
                  index: _selectedIndex,
                  children: _homeOptions,
                )),
          ),
          BottomNavigationBar(
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              items: [
                BottomNavigationBarItem(
                    icon: Icon(Icons.fastfood), label: "Platillos"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.list_alt), label: "Órdenes")
              ])
        ]));
  }
}
