import 'package:digital_menu/src/pages/reportes/graficas.dart';
import 'package:digital_menu/src/pages/reportes/reportes_ordenes.dart';
import 'package:flutter/material.dart';
import '../../widgets/navbar.dart';

class Reportes extends StatefulWidget {
  const Reportes({super.key});

  @override
  State<Reportes> createState() => _ReportesState();
}

class _ReportesState extends State<Reportes> {
  int _selectedIndex = 0;
  final List<Widget> _reportesOptions = [Graficas(), ReporteOrden()];
  @override
  Widget build(BuildContext context) {
    return NavBar(
        title: const Text("Reportes",
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
                  children: _reportesOptions,
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
                BottomNavigationBarItem(
                    icon: Icon(Icons.trending_up), label: "Estadísticas"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.edit_document), label: "Reportes")
              ])
        ]));
  }
}
