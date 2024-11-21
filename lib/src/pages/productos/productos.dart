import 'package:digital_menu/src/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:side_panel/side_panel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class Productos extends StatefulWidget {
  const Productos({super.key});

  @override
  State<Productos> createState() => __ProductosState();
}

class __ProductosState extends State<Productos> {
  List<Map<String, dynamic>> _productsList = [];
  List<Map<String, dynamic>> lowStock = [];
  bool bajoStock = false;
  SidePanelController _sidePanelController = SidePanelController();
  Map<String, dynamic>? selectedItem = {};
  String? uploadedFileName;

  void getProducts() async {
    var listaIngredientes = await supabase.from('ingredientes').select('*');
    List<Map<String, dynamic>> ingredientesConTipo =
        listaIngredientes.map((ingrediente) {
      return {...ingrediente, "tipo": "ingrediente"};
    }).toList();
    var listaBebidas = await supabase.from("bebidas").select('*');
    List<Map<String, dynamic>> bebidasConTipo = listaBebidas.map((bebida) {
      return {...bebida, "tipo": "bebida"};
    }).toList();
    setState(() {
      _productsList = [...ingredientesConTipo, ...bebidasConTipo];
    });
  }

  void getLowStockProducts() async {
    var ingredientes = await supabase
        .from('ingredientes')
        .select('*')
        .lt('cantidad_disponible', 5);
    var bebidas =
        await supabase.from('bebidas').select('*').lt('cantidad_disponible', 5);
    List<Map<String, dynamic>> ingredientesConTipo =
        ingredientes.map((ingrediente) {
      return {...ingrediente, "tipo": "ingrediente"};
    }).toList();
    List<Map<String, dynamic>> bebidasConTipo = bebidas.map((bebida) {
      return {...bebida, "tipo": "bebida"};
    }).toList();
    setState(() {
      lowStock = [...ingredientesConTipo, ...bebidasConTipo];
      lowStock.isNotEmpty ? bajoStock = true : bajoStock = false;
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
    getProducts();
    getLowStockProducts();
    print(lowStock);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Stack(children: [
      SidePanel(
          controller: _sidePanelController,
          right: Panel(
              size: 500,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  VerticalDivider(
                    width: 10,
                    color: Colors.grey,
                  ),
                  SingleChildScrollView(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    _sidePanelController.hideRightPanel();
                                    setState(() {
                                      selectedItem = {};
                                    });
                                  },
                                  icon: Icon(Icons.close)),
                              SizedBox(
                                width: 350,
                              )
                            ]),
                        Text(
                          "Detalles del producto",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Image.network(getImageUrl(selectedItem!),
                            width: 100, height: 100),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Nombre del producto:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        Text(
                          selectedItem?['nombre'] ?? 'Sin nombre',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          "Descripción: ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        Text(
                          selectedItem?['descripcion'] ?? 'Sin descripción',
                          style: TextStyle(fontSize: 20),
                        ),
                        if (selectedItem?['tipo'] == 'bebida') ...[
                          Text(
                            "Precio de venta: ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          Text(
                            selectedItem?['precio'].toString() ?? '0',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                        Text(
                          "Precio de compra: ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        Text(
                          "\$${selectedItem?['precio_compra'].toString() ?? '0'}",
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          "Cantidad Disponible:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        Text(
                          selectedItem?['cantidad_disponible'].toString() ??
                              '0',
                          style: TextStyle(fontSize: 18),
                        ),
                        if (selectedItem?['tipo'] == 'ingrediente') ...[
                          Text(
                            "Unidad de medida: ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                          Text(
                            selectedItem?['unidad_medida'] ?? 'Unidades',
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ]))
                ],
              )),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 10,
              ),
              const Text("Productos",
                  textAlign: TextAlign.start,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26)),
              SizedBox(
                height: 20,
              ),
              Expanded(
                  child: SingleChildScrollView(
                child: DataTable(
                    headingRowColor: MaterialStateColor.resolveWith((states) {
                      return Colors.black;
                    }),
                    columns: const [
                      DataColumn(
                          label: Text("Categoría",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text("Nombre",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text("Descripción",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text("Precio",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text("Cantidad disponible",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text("Detalles",
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)))
                    ],
                    rows: _productsList.map((producto) {
                      return DataRow(cells: [
                        DataCell(Text(producto['tipo'] ?? 'ingrediente')),
                        DataCell(
                          Text(producto['nombre'] ?? 'Sin nombre'),
                        ),
                        DataCell(
                            Text(producto['descripcion'] ?? 'Sin descripción')),
                        DataCell(
                            Text(producto["precio_compra"].toString() ?? '0')),
                        DataCell(Text(
                            producto["cantidad_disponible"].toString() ?? '0')),
                        DataCell(IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () {
                            setState(() {
                              selectedItem = producto;
                            });
                            _sidePanelController.showRightPanel();
                          },
                        ))
                      ]);
                    }).toList()),
              ))
            ],
          )),
      NotificacionBajoStock(
          mostrarNotificacion: bajoStock,
          onClose: () {
            setState(() {
              bajoStock = false;
            });
          },
          productos: lowStock.length)
    ]));
  }
}
