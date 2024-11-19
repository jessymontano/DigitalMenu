import 'package:digital_menu/src/widgets/button.dart';
import 'package:digital_menu/src/widgets/input.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:digital_menu/src/widgets/image_uploader.dart';
import 'package:side_panel/side_panel.dart';

final supabase = Supabase.instance.client;

class OrdenAdmin extends StatefulWidget {
  const OrdenAdmin({super.key});

  @override
  State<OrdenAdmin> createState() => _OrdenAdminState();
}

class _OrdenAdminState extends State<OrdenAdmin> {
  List<Map<String, dynamic>> _orderList = [];
  final SidePanelController _sidePanelController = SidePanelController();
  Map<String, dynamic>? selectedItem;
  List<dynamic> orderDetails = [];

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

  Future<void> getOrderDetails(int orderId) async {
    var orderProducts = await supabase
        .rpc('obtener_detalles_orden', params: {'id_orden_input': orderId});
    setState(() {
      orderDetails = orderProducts;
    });
  }

  void deleteElement(int orderId) async {
    await supabase.from('ordenes').delete().eq('id_orden', orderId);
    await supabase.from('detalle_orden').delete().eq('id_orden', orderId);
    _sidePanelController.hideRightPanel();
    getOrders();
  }

  @override
  void initState() {
    super.initState();
    getOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: SidePanel(
            controller: _sidePanelController,
            right: Panel(
                size: 400,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    VerticalDivider(
                      width: 10,
                      color: Colors.grey,
                    ),
                    SizedBox(
                        width: 300,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      _sidePanelController.hideRightPanel();
                                      setState(() {
                                        selectedItem = null;
                                      });
                                    },
                                    icon: const Icon(Icons.close)),
                                SizedBox(
                                  width: 250,
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Detalles de la Orden ${selectedItem?['id_orden'].toString()}",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                                "Nombre del cliente: ${selectedItem?['nombre_cliente']}"),
                            Text("Artículos:"),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: orderDetails.map((detalle) {
                                    return ListTile(
                                      title: Text(detalle['nombre_articulo']),
                                      subtitle: Text(
                                          "Cantidad: ${detalle['cantidad']}"),
                                      trailing: Text("\$${detalle['precio']}"),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text("Total: ${selectedItem?['total'].toString()}"),
                            Text("Tipo de pago: ${selectedItem?['tipo_pago']}"),
                            SizedBox(
                              height: 20,
                            ),
                            Button(
                                text: 'Eliminar Orden',
                                size: Size(250, 150),
                                onPressed: () {
                                  print(selectedItem);
                                  deleteElement(selectedItem?['id_orden']);
                                })
                          ],
                        )),
                  ],
                )),
            child: Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  SizedBox(
                    height: 10,
                  ),
                  const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Administrar Órdenes",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 26),
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
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )),
                          DataColumn(
                              label: Text(
                            "Estado",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )),
                          DataColumn(
                              label: Text(
                            "Nombre del cliente",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )),
                          DataColumn(
                              label: Text(
                            "Nombre del empleado",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )),
                          DataColumn(
                              label: Text(
                            "Total",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )),
                          DataColumn(
                              label: Text(
                            "Ver detalles",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ))
                        ],
                        rows: _orderList.map((elemento) {
                          return DataRow(cells: [
                            DataCell(
                              Text(elemento['id_orden'].toString()),
                            ),
                            DataCell(Text(elemento['estado'])),
                            DataCell(Text(elemento["nombre_cliente"])),
                            DataCell(Text('aa')),
                            DataCell(Text(elemento['total'].toString())),
                            DataCell(IconButton(
                              icon: const Icon(Icons.menu),
                              onPressed: () async {
                                await getOrderDetails(elemento['id_orden']);
                                setState(() {
                                  selectedItem = elemento;
                                });
                                _sidePanelController.showRightPanel();
                              },
                            ))
                          ]);
                        }).toList()),
                  )),
                ]))));
  }
}
