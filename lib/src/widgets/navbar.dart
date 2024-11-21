import "package:digital_menu/src/pages/admin/admin.dart";
import "package:digital_menu/src/pages/login/login.dart";
import "package:digital_menu/src/pages/productos/productos_home.dart";
import "package:digital_menu/src/pages/reportes/reportes.dart";
import 'package:flutter/material.dart';
import "package:shared_preferences/shared_preferences.dart";
import "../pages/configuracion/configuracion.dart";
import "../pages/home/home.dart";

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
      drawer: const SideBar(),
      body: body,
    ));
  }
}

class SideBar extends StatefulWidget {
  const SideBar({super.key});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  bool _userIsAdmin = false;
  String _userName = "Usuario";
  String _userEmail = "Email";

  Future<void> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String rol = prefs.getString('userRole')!;
    String username = prefs.getString("username")!;
    String email = prefs.getString("email")!;
    setState(() {
      _userIsAdmin = rol == 'admin';
      _userName = username;
      _userEmail = email;
    });
  }

  Future<void> signout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('name');
    await prefs.remove('email');
    await prefs.remove('userRole');
    await prefs.remove('userId');
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Column(children: [
          Expanded(
              child: ListView(padding: EdgeInsets.zero, children: [
            DrawerHeader(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.portrait_rounded,
                    size: 50,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text(_userName), Text(_userEmail)],
                  )
                ],
              ),
            ),
            ListTile(
              title: const Text('Menu principal'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Home()));
              },
            ),
            ListTile(
              title: const Text('Productos'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProductosHome()));
              },
            ),
            ListTile(
              title: const Text('Reportes'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Reportes()));
              },
            ),
            if (_userIsAdmin)
              ListTile(
                title: const Text('Área de administración'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const Admin()));
                },
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
            ListTile(
                title: const Text("Salir"),
                onTap: () {
                  signout();
                  Navigator.push(context,
                      MaterialPageRoute(builder: ((context) => Login())));
                })
          ])),
          Container(
            height: 50,
            color: Colors.black,
            child: Center(
              child: Image.asset("logo.jpg"),
            ),
          )
        ]));
  }
}
