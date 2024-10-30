import 'package:flutter/material.dart';
import '../../widgets/navbar.dart';
import 'respaldos.dart';

class Configuracion extends StatefulWidget {
  const Configuracion({super.key});
  @override
  State<Configuracion> createState() => _ConfiguracionState();
}

class _ConfiguracionState extends State<Configuracion> {
  int _selectedIndex = 0;

  //TODO: agregar el resto de las pantallas de configuración
  final List<Widget> _configOptions = [
    const Text("Datos de la empresa"),
    const Text("Historial de facturación"),
    const Text("Propinas"),
    const Text("Horario de turnos"),
    const Text("Fecha y hora"),
    Respaldos()
  ];
  @override
  Widget build(BuildContext context) {
    void onItemSelected(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    return NavBar(
        title: const Text(
          "Configuración General",
          style: TextStyle(color: Colors.white),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 300,
                  height: 600,
                  decoration: const BoxDecoration(
                      border: Border(
                          right: BorderSide(color: Colors.black, width: 2))),
                  child: ListView(
                    //TODO: cambiar color de la opción seleccionada
                    children: [
                      ListTile(
                          title: const Text("Datos de la empresa"),
                          selected: _selectedIndex == 0,
                          onTap: () => onItemSelected(0)),
                      ListTile(
                          title: const Text("Historial de facturación"),
                          selected: _selectedIndex == 1,
                          onTap: () => onItemSelected(1)),
                      ListTile(
                          title: const Text("Propinas"),
                          selected: _selectedIndex == 2,
                          onTap: () => onItemSelected(2)),
                      ListTile(
                          title: const Text("Horario de turnos"),
                          selected: _selectedIndex == 3,
                          onTap: () => onItemSelected(3)),
                      ListTile(
                          title: const Text("Fecha y hora"),
                          selected: _selectedIndex == 4,
                          onTap: () => onItemSelected(4)),
                      ListTile(
                          title: const Text("Respaldos"),
                          selected: _selectedIndex == 5,
                          onTap: () => onItemSelected(5)),
                    ],
                  ),
                ),
                Expanded(
                    child: Container(
                  padding: const EdgeInsets.all(20),
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: _configOptions,
                  ),
                ))
              ],
            )
          ],
        ));
  }
}
