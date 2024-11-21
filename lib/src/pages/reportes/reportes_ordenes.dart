import 'package:digital_menu/src/widgets/generar_reporte.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class ReporteOrden extends StatefulWidget {
  const ReporteOrden({super.key});

  @override
  State<ReporteOrden> createState() => _ReporteOrdenState();
}

class _ReporteOrdenState extends State<ReporteOrden> {
  List<Map<String, dynamic>> _orderList = [];

  Future<void> getOrders() async {
    final resultado = await supabase.from('ordenes').select('*');
    setState(() {
      _orderList = resultado;
    });
  }

  Future<String> fetchUserName(Map<String, dynamic> orden) async {
    var empleado = await supabase
        .from('usuarios')
        .select('nombre')
        .eq('id_usuario', orden['id_usuario'])
        .maybeSingle();
    return empleado?['nombre'];
  }

  @override
  void initState() {
    super.initState();
    getOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SizedBox(
        height: 10,
      ),
      const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          "Administrar Órdenes",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
        ),
        SizedBox(
          width: 360,
        )
      ]),
      SizedBox(
        height: 20,
      ),
      Expanded(
          child: SingleChildScrollView(
        child: DataTable(
            headingRowColor: MaterialStateColor.resolveWith(
              (states) {
                return Colors.black;
              },
            ),
            columns: const [
              DataColumn(
                  label: Text(
                "ID",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
              DataColumn(
                  label: Text(
                "Estado",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
              DataColumn(
                  label: Text(
                "Nombre del cliente",
                overflow: TextOverflow.ellipsis,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
              DataColumn(
                  label: Text(
                "Nombre del empleado",
                overflow: TextOverflow.ellipsis,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
              DataColumn(
                  label: Text(
                "Total",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
              DataColumn(
                  label: Text(
                "Imprimir",
                overflow: TextOverflow.ellipsis,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ))
            ],
            rows: _orderList.map((elemento) {
              return DataRow(cells: [
                DataCell(
                  Text(elemento['id_orden'].toString()),
                ),
                DataCell(Text(elemento['estado'])),
                DataCell(Text(elemento["nombre_cliente"])),
                DataCell(Text('Empleado')),
                DataCell(Text(elemento['total'].toString())),
                DataCell(Reporte(id: elemento['id_orden']))
              ]);
            }).toList()),
      )),
    ]));
  }
}
