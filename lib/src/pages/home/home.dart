import 'package:digital_menu/src/pages/home/ordenes.dart';
import 'package:digital_menu/src/pages/home/platillos.dart';
import 'package:flutter/material.dart';
import '../../widgets/navbar.dart';

class Home extends StatefulWidget {
  final String? successMessage;
  const Home({super.key, this.successMessage});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  final List<Widget> _homeOptions = [const Platillos(), Ordenes()];
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.successMessage!),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
    return NavBar(
        title: const Text("Ordenar",
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
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
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.red,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              items: const [
                //TODO: cambiar iconos y color del icono seleccionado
                BottomNavigationBarItem(
                    icon: Icon(Icons.fastfood), label: "Platillos"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.list_alt), label: "Órdenes")
              ])
        ]));
  }
}
