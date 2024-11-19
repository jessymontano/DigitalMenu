import 'package:digital_menu/src/pages/productos/compras.dart';
import 'package:digital_menu/src/pages/productos/productos.dart';
import 'package:flutter/material.dart';
import '../../widgets/navbar.dart';

class ProductosHome extends StatefulWidget {
  const ProductosHome({super.key});

  @override
  State<ProductosHome> createState() => _ProductosHomeState();
}

class _ProductosHomeState extends State<ProductosHome> {
  int _selectedIndex = 0;
  final List<Widget> _homeOptions = [const Productos(), Compras()];
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
                    icon: Icon(Icons.inventory_2_outlined), label: "Productos"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_cart), label: "Compras")
              ])
        ]));
  }
}
