import 'package:digital_menu/src/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:side_panel/side_panel.dart';

final supabase = Supabase.instance.client;

class Compras extends StatefulWidget {
  const Compras({super.key});

  @override
  State<Compras> createState() => _ComprasState();
}

class _ComprasState extends State<Compras> {
  List<Map<String, dynamic>> _compraList = [];
  final SidePanelController _sidePanelController = SidePanelController();
  Map<String, dynamic>? selectedItem;
  List<dynamic> compraDetails = [];
  List<Map<String, dynamic>> ingredients = [];
  List<Map<String, dynamic>> selectedIngredients = [];
  Map<String, dynamic>? selectedIngredient;
  TextEditingController _cantidadController = TextEditingController();
  bool isAdding = false;
  double total = 0;

  Future<void> getCompras() async {
    final resultado = await supabase.from('compras').select('*');
    setState(() {
      _compraList = resultado;
    });
  }

  Future<void> getCompraDetails(int compraId) async {
    var compraProductos = await supabase
        .rpc('obtener_detalles_compra', params: {'id_compra_input': compraId});
    setState(() {
      compraDetails = compraProductos;
    });
  }

  void deleteCompra(int compraId) async {
    await supabase.from('compras').delete().eq('id_compra', compraId);
    await supabase.from('detalle_compra').delete().eq('id_compra', compraId);
    _sidePanelController.hideRightPanel();
    getCompras();
  }

  Future<void> getProducts() async {
    var ingredientes = await supabase.from('ingredientes').select('*');
    var bebidas = await supabase.from('bebidas').select('*');
    List<Map<String, dynamic>> ingredientesCantidad =
        ingredientes.map((ingrediente) {
      return {...ingrediente, "cantidad": 1, 'tipo': 'ingrediente'};
    }).toList();
    List<Map<String, dynamic>> bebidasCantidad = bebidas.map((bebida) {
      return {...bebida, "cantidad": 1, 'tipo': 'bebida'};
    }).toList();
    setState(() {
      ingredients = [...ingredientesCantidad, ...bebidasCantidad];
    });
  }

  void addIngredient() {
    if (selectedIngredients.contains(selectedIngredient)) {
      Map<String, dynamic> element = selectedIngredients
          .elementAt(selectedIngredients.indexOf(selectedIngredient!));
      setState(() {
        element.update('cantidad',
            (value) => value + int.tryParse(_cantidadController.text));
      });
    } else {
      setState(() {
        selectedIngredient!.update(
            'cantidad', (value) => int.tryParse(_cantidadController.text));
        selectedIngredients.add(selectedIngredient!);
      });
    }
    _cantidadController.clear();
  }

  void getTotalPrice() {
    double precioTotal = 0;
    print(selectedIngredients);
    for (var elemento in selectedIngredients) {
      precioTotal += elemento['precio_compra'] * elemento['cantidad'];
    }
    setState(() {
      total = precioTotal;
    });
  }

  Future<void> savePurchase() async {
    final compra = await supabase.from('compras').insert({
      'total': total,
    }).select();

    for (var ingrediente in selectedIngredients) {
      await Supabase.instance.client.from('detalle_compra').insert({
        'id_compra': compra[0]['id_compra'],
        'id_ingrediente':
            ingrediente['id_ingrediente'] ?? null, // Null si es una bebida
        'id_bebida': ingrediente['id_bebida'] ?? null, // Null si es un platillo
        'cantidad': ingrediente['cantidad'],
        'tipo': ingrediente['tipo']
      });
    }
    selectedIngredients = [];
    getCompras();
  }

  @override
  void initState() {
    super.initState();
    getCompras();
    getProducts();
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
                              isAdding = false;
                            });
                          },
                          icon: const Icon(Icons.close),
                        ),
                        SizedBox(width: 250),
                      ],
                    ),
                    SizedBox(height: 10),
                    isAdding
                        ? Text("Registrar compra",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold))
                        : Text(
                            "Detalles de la Compra ${selectedItem?['id_compra']}",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                    SizedBox(height: 10),
                    if (isAdding)
                      Expanded(
                        child: Column(
                          children: [
                            DropdownButtonFormField<Map<String, dynamic>>(
                              hint: const Text("Seleccionar producto"),
                              items: ingredients.map((ingrediente) {
                                return DropdownMenuItem<Map<String, dynamic>>(
                                  value: ingrediente,
                                  child: Text(ingrediente['nombre']),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedIngredient = value;
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _cantidadController,
                              decoration: const InputDecoration(
                                labelText: "Cantidad",
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: () {
                                addIngredient();
                                getTotalPrice();
                              },
                              icon: const Icon(Icons.add),
                              label: const Text("Añadir"),
                              style: ElevatedButton.styleFrom(
                                  maximumSize: Size(200, 100),
                                  backgroundColor:
                                      const Color.fromARGB(255, 212, 10, 8),
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.fromLTRB(30, 20, 30, 20),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10))),
                            ),
                            Expanded(
                              child: ListView(
                                children:
                                    selectedIngredients.map((ingrediente) {
                                  return ListTile(
                                    title: Text(ingrediente['nombre']),
                                    subtitle: Text(
                                        "Cantidad: ${ingrediente['cantidad']}, Subtotal: ${ingrediente['precio_compra'] * ingrediente['cantidad']}"),
                                  );
                                }).toList(),
                              ),
                            ),
                            Text(
                              "Total: ${total.toStringAsFixed(2)}",
                              style: TextStyle(fontSize: 24),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Button(
                              onPressed: () {
                                savePurchase();
                                _sidePanelController.hideRightPanel();
                              },
                              text: "Registrar compra",
                              size: Size(250, 150),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: compraDetails.map((detalle) {
                              return ListTile(
                                title: Text(detalle['nombre_articulo']),
                                subtitle: Text(
                                    "Cantidad: ${detalle['cantidad']} unidades"),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Total: ${selectedItem?['total'].toString()}",
                        style: TextStyle(fontSize: 24),
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
        child: Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Historial de compras",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                  ),
                  Button(
                      text: "Registrar compra",
                      size: Size(250, 150),
                      onPressed: () {
                        setState(() {
                          isAdding = true;
                          selectedItem = null;
                        });
                        _sidePanelController.showRightPanel();
                      }),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: DataTable(
                    headingRowColor: MaterialStateColor.resolveWith((states) {
                      return Colors.black;
                    }),
                    columns: const [
                      DataColumn(
                          label: Text(
                        "ID",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )),
                      DataColumn(
                          label: Text(
                        "Fecha y Hora",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )),
                      DataColumn(
                          label: Text(
                        "Total",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )),
                      DataColumn(
                          label: Text(
                        "Ver detalles",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )),
                    ],
                    rows: _compraList.map((elemento) {
                      return DataRow(cells: [
                        DataCell(Text(elemento['id_compra'].toString())),
                        DataCell(Text(elemento['fecha_y_hora'].toString())),
                        DataCell(Text(elemento['total'].toString())),
                        DataCell(IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () async {
                            await getCompraDetails(elemento['id_compra']);
                            setState(() {
                              selectedItem = elemento;
                            });
                            _sidePanelController.showRightPanel();
                          },
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
