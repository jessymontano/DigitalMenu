import 'package:flutter/material.dart';
import "../pages/configuracion.dart";

class NavBar extends StatelessWidget {
  final Widget body;
  final Text title;
  const NavBar({super.key, required this.body, required this.title});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: title,
        backgroundColor: Colors.black,
        leading: Builder(
          builder: (context) {
            return IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: const Icon(
                  Icons.menu,
                  color: Colors.white,
                ));
          },
        ),
      ),
      drawer: Drawer(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: ListView(padding: EdgeInsets.zero, children: [
            const DrawerHeader(
              child: Text('Menu'),
            ),
            ListTile(
              title: const Text('Menu principal'),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Productos'),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Reportes'),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Área de administración'),
              onTap: () {},
            ),
            ListTile(
              title: const Text('Configuración'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Configuracion()));
              },
            ),
          ])),
      body: body,
    ));
  }
}
