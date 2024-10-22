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

  void addToOrder(Map<String, dynamic> element) {
    if (!_ordering) {
      setState(() {
        _ordering = true;
        currentOrder.add(element);
      });
    } else {
      setState(() {
        currentOrder.add(element);
      });
    }
  }

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
                      padding: EdgeInsets.all(20),
                      child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 200,
                                  childAspectRatio: 1,
                                  crossAxisSpacing: 30,
                                  mainAxisSpacing: 20),
                          itemCount: menuItems.length,
                          itemBuilder: (BuildContext context, index) {
                            return InkWell(
                                onTap: () {
                                  addToOrder(menuItems[index]);
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 247, 247, 247),
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
                padding: EdgeInsets.all(50),
                child: SingleChildScrollView(
                  child: Column(children: [
                    Text('Orden'),
                    Divider(height: 10),
                    ...currentOrder.map((item) {
                      return ListTile(
                        leading: Image.network(
                          getImageUrl(item),
                          width: 50,
                          height: 50,
                        ),
                        title: Text(item['nombre']),
                        subtitle:
                            Text(item['descripcion'] ?? 'Sin descripción'),
                      );
                    }).toList(),
                  ]),
                )))
    ]);
  }
}
