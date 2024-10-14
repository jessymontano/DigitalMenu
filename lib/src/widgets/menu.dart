import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  List<Map<String, dynamic>> _menuList = [];

  Future<void> getMenu() async {
    var platillos = await supabase
        .from('platillos')
        .select('nombre, descripcion, precio, imagen');
    List<Map<String, dynamic>> platillosConTipo = platillos.map((platillo) {
      return {...platillo, "tipo": "platillo"};
    }).toList();
    var bebidas = await supabase
        .from("bebidas")
        .select("nombre, descripcion, precio, imagen");
    List<Map<String, dynamic>> bebidasConTipo = bebidas.map((bebida) {
      return {...bebida, "tipo": "bebida"};
    }).toList();
    setState(() {
      _menuList = [...platillosConTipo, ...bebidasConTipo];
    });
  }

  @override
  void initState() {
    super.initState();
    getMenu();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: DataTable(
          columns: [
            DataColumn(label: Text("Tipo")),
            DataColumn(label: Text("Nombre")),
            DataColumn(label: Text("Descripción")),
            DataColumn(label: Text("Precio")),
            DataColumn(label: Text("Editar"))
          ],
          rows: _menuList.map((elemento) {
            return DataRow(cells: [
              DataCell(
                Text(elemento['tipo'].toString()),
              ),
              DataCell(Text(elemento['nombre'])),
              DataCell(Text(elemento["descripcion"] ?? "Sin descripción")),
              DataCell(Text(elemento["precio"].toString())),
              DataCell(IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {},
              ))
            ]);
          }).toList()),
    );
  }
}
