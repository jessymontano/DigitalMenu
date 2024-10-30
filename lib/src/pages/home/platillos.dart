import 'package:digital_menu/src/widgets/button.dart';
import 'package:digital_menu/src/pages/home/pagos.dart';
import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class Platillos extends StatefulWidget {
  const Platillos({super.key});

  @override
  State<Platillos> createState() => _PlatillosState();
}

class _PlatillosState extends State<Platillos> {
  List<Map<String, dynamic>> menuItems = [];
  bool _ordering = false;
  List<Map<String, dynamic>> currentOrder = [];
  num totalPrice = 0;
  void addToOrder(Map<String, dynamic> element) {
    if (currentOrder.contains(element)) {
      Map<String, dynamic> orderElement =
          currentOrder.elementAt(currentOrder.indexOf(element));
      setState(() {
        _ordering = true;
        orderElement.update('cantidad', (value) => value + 1);
      });
    } else {
      setState(() {
        _ordering = true;
        currentOrder.add(element);
      });
    }
  }

  Future<void> getMenu() async {
    var platillos = await supabase
        .from('platillos')
        .select('id_platillo, nombre, descripcion, precio, imagen');
    List<Map<String, dynamic>> platillosConTipo = platillos.map((platillo) {
      return {...platillo, "tipo": "platillo", 'cantidad': 1};
    }).toList();
    var bebidas = await supabase
        .from("bebidas")
        .select("id_bebida, nombre, descripcion, precio, imagen");
    List<Map<String, dynamic>> bebidasConTipo = bebidas.map((bebida) {
      return {...bebida, "tipo": "bebida", 'cantidad': 1};
    }).toList();
    setState(() {
      menuItems = [...platillosConTipo, ...bebidasConTipo];
    });
  }

  String getImageUrl(Map<String, dynamic> elemento) {
    String? imageName = elemento['imagen'];
    if (imageName != null) {
      return "https://kgxonqwulbraeezxplxw.supabase.co/storage/v1/object/public/img/images/$imageName";
    }
    return "https://via.placeholder.com/150";
  }

  void getTotalPrice() {
    num total = 0;
    for (var elemento in currentOrder) {
      total += elemento['precio'] * elemento['cantidad'];
    }
    setState(() {
      totalPrice = total;
    });
  }

  void cancelOrder() {
    setState(() {
      currentOrder = [];
      _ordering = false;
      totalPrice = 0;
    });
  }

  @override
  void initState() {
    super.initState();
    getMenu();
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
          flex: 3,
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black,
                  ),
                  child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 200,
                                  childAspectRatio: 1,
                                  crossAxisSpacing: 30,
                                  mainAxisSpacing: 20),
                          itemCount: menuItems.length,
                          itemBuilder: (BuildContext context, index) {
                            return InkWell(
                                onTap: () {
                                  addToOrder(menuItems[index]);
                                  getTotalPrice();
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 247, 247, 247),
                                      borderRadius: BorderRadius.circular(15)),
                                  child: Column(
                                    children: [
                                      Image.network(
                                        getImageUrl(menuItems[index]),
                                        width: 150,
                                        height: 150,
                                      ),
                                      Text(menuItems[index]['nombre'] +
                                          "  \$" +
                                          menuItems[index]['precio'].toString())
                                    ],
                                  ),
                                ));
                          }))))),
      if (_ordering)
        Expanded(
            flex: 1,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Column(children: [
                  const Text('Orden'),
                  const Divider(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(children: [
                        ...currentOrder.map((item) {
                          return ListTile(
                            isThreeLine: true,
                            leading: Image.network(
                              getImageUrl(item),
                              width: 50,
                              height: 50,
                            ),
                            title: Text(item['nombre']),
                            subtitle: Text((item['descripcion'] ??
                                    'Sin descripción') +
                                '\nCantidad: ${item['cantidad'].toString()}'),
                            trailing: Text('\$${item['precio'].toString()}'),
                          );
                        }),
                      ]),
                    ),
                  ),
                  Container(
                      color: Colors.black,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                        child: Column(
                          children: [
                            Text(
                              'Total: \$$totalPrice',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Button(
                                    text: 'Cancelar',
                                    size: const Size(150, 100),
                                    onPressed: () {
                                      cancelOrder();
                                    }),
                                Button(
                                    text: 'Pagar',
                                    size: const Size(150, 100),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Pagos(
                                                    total: totalPrice,
                                                    currentOrder: currentOrder,
                                                  )));
                                    })
                              ],
                            )
                          ],
                        ),
                      ))
                ])))
    ]);
  }
}
