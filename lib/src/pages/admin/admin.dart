import 'package:digital_menu/src/pages/admin/menu.dart';
import 'package:digital_menu/src/pages/admin/ordenes_admin.dart';
import 'package:digital_menu/src/widgets/navbar.dart';
import 'package:digital_menu/src/pages/admin/productos_admin.dart';
import 'package:digital_menu/src/pages/admin/usuarios.dart';
import 'package:digital_menu/src/pages/admin/compras_admin.dart';
import 'package:flutter/material.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});
  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  int _selectedIndex = 0; //Index del menú de abajo

  final List<Widget> _adminOptions = [
    //pantallas que se muestran al elegir una opción del menú
    const Menu(),
    const ProductosAdmin(),
    const OrdenAdmin(),
    const Usuarios(),
    const ComprasAdmin(),
  ];

  @override
  Widget build(BuildContext context) {
    void onItemSelected(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    return NavBar(
        body: Row(
          children: [
            Padding(
                padding: EdgeInsets.all(10),
                child: Container(
                  width: 300,
                  height: 600,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: Colors.black,
                  ),
                  child: ListView(
                    padding: EdgeInsets.all(5),
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.all(10),
                        leading: const Icon(Icons.menu_book),
                        title: const Text(
                          "Menu",
                          style: TextStyle(color: Colors.white),
                        ),
                        selected: _selectedIndex == 0,
                        onTap: () => onItemSelected(0),
                        selectedColor: Colors.red,
                      ),
                      ListTile(
                          contentPadding: EdgeInsets.all(10),
                          leading: const Icon(Icons.inventory),
                          title: const Text(
                            "Productos",
                            style: TextStyle(color: Colors.white),
                          ),
                          selected: _selectedIndex == 1,
                          onTap: () => onItemSelected(1),
                          selectedColor: Colors.red),
                      ListTile(
                          contentPadding: EdgeInsets.all(10),
                          leading: const Icon(Icons.list_alt),
                          title: const Text(
                            "Órdenes",
                            style: TextStyle(color: Colors.white),
                          ),
                          selected: _selectedIndex == 2,
                          onTap: () => onItemSelected(2),
                          selectedColor: Colors.red),
                      ListTile(
                          contentPadding: EdgeInsets.all(10),
                          leading: const Icon(Icons.people_alt),
                          title: const Text(
                            "Usuarios",
                            style: TextStyle(color: Colors.white),
                          ),
                          selected: _selectedIndex == 3,
                          onTap: () => onItemSelected(3),
                          selectedColor: Colors.red),
                      ListTile(
                          contentPadding: EdgeInsets.all(10),
                          leading: const Icon(Icons.shopping_cart),
                          title: const Text(
                            "Compras",
                            style: TextStyle(color: Colors.white),
                          ),
                          selected: _selectedIndex == 4,
                          onTap: () => onItemSelected(4),
                          selectedColor: Colors.red),
                      ListTile(
                          contentPadding: EdgeInsets.all(10),
                          leading: const Icon(Icons.exit_to_app),
                          title: const Text(
                            "Salir",
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () => Navigator.of(context).pop())
                    ],
                  ),
                )),
            Flexible(
                child: Container(
              padding: const EdgeInsets.all(20),
              child: IndexedStack(
                index: _selectedIndex,
                children: _adminOptions,
              ),
            ))
          ],
        ),
        title: const Text(
          "Área De Administración",
          style: TextStyle(color: Colors.white),
        ));
  }
}
