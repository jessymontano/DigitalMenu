import 'package:digital_menu/src/pages/admin/menu.dart';
import 'package:digital_menu/src/widgets/navbar.dart';
import 'package:digital_menu/src/pages/admin/productos_admin.dart';
import 'package:digital_menu/src/pages/admin/usuarios.dart';
import 'package:flutter/material.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});
  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  int _selectedIndex = 0; //Index del menú de abajo

  //TODO: agregar pantalla de Productos
  final List<Widget> _adminOptions = [
    //pantallas que se muestran al elegir una opción del menú
    const Usuarios(),
    const Menu(),
    const ProductosAdmin()
  ];

  @override
  Widget build(BuildContext context) {
    return NavBar(
        body: Column(
          children: [
            Expanded(
                child: Container(
              padding: const EdgeInsets.all(20),
              child: IndexedStack(
                index: _selectedIndex,
                children: _adminOptions,
              ),
            )),
            BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                items: const [
                  //TODO: cambiar íconos
                  BottomNavigationBarItem(
                      label: "Usuarios",
                      icon: Icon(Icons.supervised_user_circle)),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.food_bank_rounded), label: "Menú"),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.shopping_cart), label: "Productos")
                ])
          ],
        ),
        title: const Text(
          "Área De Administración",
          style: TextStyle(color: Colors.white),
        ));
  }
}
