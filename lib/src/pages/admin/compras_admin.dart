import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:side_panel/side_panel.dart';
import 'package:digital_menu/src/widgets/button.dart';

final supabase = Supabase.instance.client;

class ComprasAdmin extends StatefulWidget {
  const ComprasAdmin({super.key});

  @override
  State<ComprasAdmin> createState() => _ComprasAdminState();
}

class _ComprasAdminState extends State<ComprasAdmin> {
  List<Map<String, dynamic>> _compraList = [];
  final SidePanelController _sidePanelController = SidePanelController();
  Map<String, dynamic>? selectedItem;
  List<dynamic> compraDetails = [];

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

  @override
  void initState() {
    super.initState();
    getCompras();
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
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                          icon: const Icon(Icons.close),
                        ),
                        SizedBox(width: 250),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Detalles de la Compra ${selectedItem?['id_compra']}",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: compraDetails.map((detalle) {
                            return ListTile(
                              title: Text(detalle['nombre_articulo']),
                              subtitle:
                                  Text("Cantidad: ${detalle['cantidad']}"),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Total: \$${selectedItem?['total'].toString()}",
                      style: TextStyle(fontSize: 24),
                    ),
                    SizedBox(height: 20),
                    Button(
                      size: Size(250, 150),
                      text: "Eliminar compra",
                      onPressed: () {
                        deleteCompra(selectedItem?['id_compra']);
                      },
                    )
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
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Administrar compras",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                  ),
                  SizedBox(width: 360),
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
