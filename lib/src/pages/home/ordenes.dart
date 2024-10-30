import 'package:digital_menu/src/widgets/button.dart';
import 'package:digital_menu/src/widgets/generar_reporte.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class Ordenes extends StatefulWidget {
  @override
  State<Ordenes> createState() => _OrdenesState();
}

class _OrdenesState extends State<Ordenes> {
  List<Map<String, dynamic>> orders = [];

  Future<void> fetchOrders() async {
    final resultado = await supabase.from('ordenes').select('*');
    setState(() {
      orders = resultado;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Ordenes'),
        Row(children: [
          Expanded(
              child: SingleChildScrollView(
                  child: Column(
                      children: orders.map((orden) {
            return Card(
                child: Column(
              children: [
                Row(
                  children: [
                    Text('Orden'),
                    Button(
                        text: 'Orden completa',
                        size: Size(200, 100),
                        onPressed: () {}),
                    Reporte(id: orden['id_orden'])
                  ],
                )
              ],
            ));
          }).toList())))
        ])
      ],
    );
  }
}
