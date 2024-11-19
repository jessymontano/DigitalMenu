import 'dart:js_util';

import 'package:digital_menu/src/widgets/button.dart';
import 'package:digital_menu/src/widgets/generar_reporte.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class Ordenes extends StatefulWidget {
  @override
  State<Ordenes> createState() => _OrdenesState();
}

class _OrdenesState extends State<Ordenes> {
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> completeOrders = [];
  List<dynamic> orderDetails = [];

  Future<void> fetchOrders() async {
    final resultado = await supabase.from('ordenes').select('*');
    List<Map<String, dynamic>> tempOrders = [];
    List<Map<String, dynamic>> tempComplete = [];
    for (var order in resultado) {
      if (order['estado'] == 'completado') {
        tempComplete.add(order);
      } else {
        tempOrders.add(order);
      }
    }
    setState(() {
      orders = tempOrders;
      completeOrders = tempComplete.reversed.toList();
    });
  }

  Future<void> completeOrder(int orderId) async {
    await supabase
        .from('ordenes')
        .update({'estado': 'completado'}).eq('id_orden', orderId);
    fetchOrders();
  }

  Future<void> getOrder(int orderId) async {
    var orderProducts = await supabase
        .rpc('obtener_detalles_orden', params: {'id_orden_input': orderId});
    setState(() {
      orderDetails = orderProducts;
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
    return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
              flex: 2,
              child: SingleChildScrollView(
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(50, 10, 50, 10),
                      child: Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                            Text(
                              "En curso",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 30),
                            ),
                            ...orders.map((orden) {
                              return Container(
                                  margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.black),
                                  child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Orden ${orden['id_orden'].toString()}',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 24),
                                              ),
                                              Button(
                                                  text: 'Orden completa',
                                                  size: Size(200, 100),
                                                  onPressed: () {
                                                    completeOrder(
                                                        orden['id_orden']);
                                                  }),
                                            ],
                                          ),
                                          Divider(
                                            height: 10,
                                            color: Colors.grey,
                                          ),
                                          Text(
                                            "Cliente: ${orden['nombre_cliente']}",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          TextButton(
                                              onPressed: () async {
                                                await getOrder(
                                                    orden['id_orden']);

                                                showModalBottomSheet(
                                                    context: context,
                                                    builder:
                                                        (BuildContext context) {
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(20.0),
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "Detalles de la Orden",
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            Flexible(
                                                                child:
                                                                    SingleChildScrollView(
                                                              child: Column(
                                                                children:
                                                                    orderDetails
                                                                        .map(
                                                                            (detalle) {
                                                                  return ListTile(
                                                                    title: Text(
                                                                        detalle[
                                                                            'nombre_articulo']),
                                                                    subtitle: Text(
                                                                        "Cantidad: ${detalle['cantidad']}"),
                                                                    trailing: Text(
                                                                        "\$${detalle['precio']}"),
                                                                  );
                                                                }).toList(),
                                                              ),
                                                            )),
                                                            Reporte(
                                                                id: orden[
                                                                    'id_orden']),
                                                            Align(
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              child:
                                                                  ElevatedButton(
                                                                onPressed: () {
                                                                  setState(() {
                                                                    orderDetails =
                                                                        [];
                                                                  });
                                                                  Navigator.pop(
                                                                      context); // Cerrar el modal
                                                                },
                                                                child: Text(
                                                                    "Cerrar"),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    });
                                              },
                                              child: Text(
                                                "Ver detalles",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )),
                                        ],
                                      )));
                            })
                          ]))))),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: const VerticalDivider(
              color: Colors.black54,
              width: 20,
            ),
          ),
          Expanded(
              flex: 2,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(50, 10, 50, 10),
                  child: Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Completadas",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 30),
                      ),
                      ...completeOrders.map((orden) {
                        return Container(
                            margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.black),
                            child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Orden ${orden['id_orden'].toString()}',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 24),
                                    ),
                                    Divider(
                                      height: 10,
                                      color: Colors.grey,
                                    ),
                                    Text(
                                      "Cliente: ${orden['nombre_cliente']}",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    TextButton(
                                        onPressed: () async {
                                          await getOrder(orden['id_orden']);

                                          showModalBottomSheet(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return Padding(
                                                  padding: const EdgeInsets.all(
                                                      20.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        "Detalles de la Orden",
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Flexible(
                                                          child:
                                                              SingleChildScrollView(
                                                        child: Column(
                                                          children: orderDetails
                                                              .map((detalle) {
                                                            return ListTile(
                                                              title: Text(detalle[
                                                                  'nombre_articulo']),
                                                              subtitle: Text(
                                                                  "Cantidad: ${detalle['cantidad']}"),
                                                              trailing: Text(
                                                                  "\$${detalle['precio']}"),
                                                            );
                                                          }).toList(),
                                                        ),
                                                      )),
                                                      Reporte(
                                                          id: orden[
                                                              'id_orden']),
                                                      Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              orderDetails = [];
                                                            });
                                                            Navigator.pop(
                                                                context); // Cerrar el modal
                                                          },
                                                          child: Text("Cerrar"),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              });
                                        },
                                        child: Text(
                                          "Ver detalles",
                                          style: TextStyle(color: Colors.white),
                                        )),
                                  ],
                                )));
                      })
                    ],
                  )),
                ),
              ))
        ]);
  }
}
