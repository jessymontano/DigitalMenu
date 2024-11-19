import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:side_panel/side_panel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:digital_menu/src/widgets/input.dart';
import 'package:digital_menu/src/widgets/button.dart';
import 'package:digital_menu/src/widgets/image_uploader.dart';

final supabase = Supabase.instance.client;

class ProductosAdmin extends StatefulWidget {
  const ProductosAdmin({super.key});

  @override
  State<ProductosAdmin> createState() => __ProductosAdminStateState();
}

class __ProductosAdminStateState extends State<ProductosAdmin> {
  List<Map<String, dynamic>> _productsList = [];
  SidePanelController _sidePanelController = SidePanelController();
  bool isEditing = false;
  bool isAdding = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? selectedItem;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _unidadController = TextEditingController();
  TextEditingController _cantidadController = TextEditingController();
  TextEditingController _precioBebidaController = TextEditingController();
  String typeValue = "ingrediente";
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

  String getImageUrl(Map<String, dynamic> elemento) {
    String? imageName = elemento['imagen'];
    if (imageName != null) {
      return "https://kgxonqwulbraeezxplxw.supabase.co/storage/v1/object/public/img/images/$imageName";
    }
    return "https://via.placeholder.com/150";
  }

  void editIngredient(Map<String, dynamic> ingrediente) {
    setState(() {
      isEditing = true;
      isAdding = false;
      selectedItem = ingrediente;
      typeValue = 'ingrediente';
      _nameController.text = selectedItem?['nombre'];
      _descriptionController.text = selectedItem?['descripcion'];
      _priceController.text = selectedItem?['precio_compra'].toString() ?? "0";
      typeValue = selectedItem?['tipo'];
      _unidadController.text = selectedItem?['unidad_medida'];
      _cantidadController.text =
          selectedItem?['cantidad_disponible'].toString() ?? "0";
    });
    _sidePanelController.showRightPanel();
  }

  void editDrink(Map<String, dynamic> bebida) {
    setState(() {
      isEditing = true;
      isAdding = false;
      selectedItem = bebida;
      typeValue = "bebida";
      _nameController.text = selectedItem?['nombre'];
      _descriptionController.text = selectedItem?['descripcion'];
      _priceController.text = selectedItem?['precio_compra'].toString() ?? "0";
      typeValue = selectedItem?['tipo'];
      _cantidadController.text =
          selectedItem?['cantidad_disponible'].toString() ?? "0";
      _precioBebidaController.text = selectedItem?['precio'].toString() ?? '0';
    });
    _sidePanelController.showRightPanel();
  }

  void addIngredient() {
    setState(() {
      isEditing = false;
      isAdding = true;
      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      typeValue = 'ingrediente';
      _unidadController.clear();
      _cantidadController.clear();
    });
    _sidePanelController.showRightPanel();
  }

  void addDrink() {
    setState(() {
      isEditing = false;
      isAdding = true;
      _nameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      typeValue = 'bebida';
      _cantidadController.clear();
      _precioBebidaController.clear();
    });
    _sidePanelController.showRightPanel();
  }

  void deleteProduct(Map<String, dynamic>? producto) async {
    String? imagePath = producto?['image'];

    if (producto != null && producto.containsKey('id_producto')) {
      if (imagePath != null) {
        await supabase.storage.from('img').remove(['images/$imagePath']);
      }
      if (producto['tipo'] == "ingrediente") {
        await supabase
            .from('ingredientes')
            .delete()
            .eq('id_ingrediente', producto["id_ingrediente"]);
        getProducts();
        setState(() {
          isAdding = false;
          isEditing = false;
          selectedItem = null;
        });
      } else {
        await supabase
            .from('bebidas')
            .delete()
            .eq('id_bebida', producto["id_bebida"]);
        getProducts();
        setState(() {
          isAdding = false;
          isEditing = false;
          selectedItem = null;
        });
      }
    }
    _sidePanelController.hideRightPanel();
  }

  void saveChanges(Map<String, dynamic>? producto) async {
    if (producto != null && producto.containsKey('id_ingrediente')) {
      await supabase.from('ingredientes').update({
        'nombre': _nameController.text,
        'descripcion': _descriptionController.text.isEmpty
            ? 'Sin descripción'
            : _descriptionController.text,
        'precio_compra': double.tryParse(_priceController.text),
        if (uploadedFileName != null) 'imagen': uploadedFileName,
        'unidad_medida': _unidadController.text,
        'cantidad_disponible': int.tryParse(_cantidadController.text),
      }).eq('id_ingrediente', producto['id_ingrediente']);
    } else if (producto != null && producto.containsKey('id_bebida')) {
      await supabase.from('bebidas').update({
        'nombre': _nameController.text,
        'descripcion': _descriptionController.text.isEmpty
            ? 'Sin descripción'
            : _descriptionController.text,
        'precio_compra': double.tryParse(_priceController.text),
        'precio': double.tryParse(_precioBebidaController.text),
        if (uploadedFileName != null) 'imagen': uploadedFileName,
        'cantidad_disponible': int.tryParse(_cantidadController.text),
      }).eq('id_bebida', producto['id_bebida']);
    } else if (producto == null && typeValue == 'ingrediente') {
      await supabase.from('ingredientes').insert({
        'nombre': _nameController.text,
        'descripcion': _descriptionController.text.isEmpty
            ? 'Sin descripción'
            : _descriptionController.text,
        'precio_compra': double.tryParse(_priceController.text),
        if (uploadedFileName != null) 'imagen': uploadedFileName,
        'unidad_medida': _unidadController.text,
        'cantidad_disponible': int.tryParse(_cantidadController.text),
      });
    } else {
      await supabase.from('bebidas').insert({
        'nombre': _nameController.text,
        'descripcion': _descriptionController.text.isEmpty
            ? 'Sin descripción'
            : _descriptionController.text,
        'precio_compra': double.tryParse(_priceController.text),
        'precio': double.tryParse(_precioBebidaController.text),
        if (uploadedFileName != null) 'imagen': uploadedFileName,
        'cantidad_disponible': int.tryParse(_cantidadController.text),
      });
    }
    getProducts();
    setState(() {
      isEditing = false;
      isAdding = false;
      selectedItem = null;
    });
    _sidePanelController.hideRightPanel();
  }

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: SidePanel(
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
                        child: Form(
                            key: _formKey,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        IconButton(
                                            onPressed: () {
                                              setState(() {
                                                isEditing = false;
                                                isAdding = false;
                                                selectedItem = null;
                                                _sidePanelController
                                                    .hideRightPanel();
                                              });
                                            },
                                            icon: Icon(Icons.close)),
                                        SizedBox(
                                          width: 350,
                                        )
                                      ]),
                                  Text(
                                    isEditing
                                        ? 'Editar información de producto'
                                        : 'Agregar nuevo producto',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  if (isEditing)
                                    Image.network(
                                      getImageUrl(selectedItem!),
                                      width: 100,
                                      height: 100,
                                    ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Input(
                                    controller: _nameController,
                                    hintText: "",
                                    labelText: 'Nombre del producto',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Ingrese un nombre';
                                      }
                                      return null;
                                    },
                                  ),
                                  Input(
                                    controller: _descriptionController,
                                    hintText: "",
                                    labelText: 'Descripción',
                                  ),
                                  if (typeValue == 'bebida')
                                    Input(
                                      controller: _precioBebidaController,
                                      hintText: "",
                                      labelText: "Precio de venta",
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Ingrese un precio';
                                        } else if (double.tryParse(value) ==
                                            null) {
                                          return 'El precio debe ser un número';
                                        }
                                        return null;
                                      },
                                    ),
                                  Input(
                                      hintText: "",
                                      labelText: typeValue == 'bebida'
                                          ? 'Precio de compra'
                                          : 'Precio',
                                      controller: _priceController),
                                  Input(
                                    controller: _cantidadController,
                                    hintText: "",
                                    labelText: "Cantidad disponible",
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Ingrese una cantidad';
                                      }
                                      return null;
                                    },
                                  ),
                                  if (typeValue == 'ingrediente')
                                    Input(
                                        hintText: "",
                                        labelText: "Unidad de medida",
                                        controller: _unidadController),
                                  ImageUploader(
                                    onImageUploaded: (fileName) {
                                      setState(() {
                                        uploadedFileName = fileName;
                                      });
                                    },
                                  ),
                                  if (isAdding)
                                    Button(
                                        size: Size(250, 100),
                                        text: "Agregar Producto",
                                        onPressed: () {
                                          if (_formKey.currentState
                                                  ?.validate() ??
                                              false) {
                                            saveChanges(null);
                                          }
                                        }),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  if (isEditing)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Button(
                                            size: Size(200, 100),
                                            text: "Eliminar Producto",
                                            onPressed: () {
                                              deleteProduct(
                                                  selectedItem?['id_producto']);
                                              setState(() {
                                                isEditing = false;
                                                selectedItem = null;
                                              });
                                            }),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Button(
                                            size: Size(200, 100),
                                            text: "Guardar cambios",
                                            onPressed: () {
                                              if (_formKey.currentState
                                                      ?.validate() ??
                                                  false) {
                                                saveChanges(selectedItem);
                                              }
                                            }),
                                      ],
                                    )
                                ])))
                  ],
                )),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Administrar productos",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 26)),
                    Button(
                      size: Size(200, 150),
                      text: "Agregar ingrediente",
                      onPressed: () {
                        addIngredient();
                      },
                    ),
                    Button(
                      size: Size(200, 150),
                      text: "Agregar bebida",
                      onPressed: () {
                        addDrink();
                      },
                    )
                  ],
                ),
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
                            label: Text("Editar",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)))
                      ],
                      rows: _productsList.map((producto) {
                        return DataRow(cells: [
                          DataCell(Text(producto['tipo'])),
                          DataCell(
                            Text(producto['nombre']),
                          ),
                          DataCell(Text(
                              producto['descripcion'] ?? 'Sin descripción')),
                          DataCell(Text(producto["precio_compra"].toString())),
                          DataCell(
                              Text(producto["cantidad_disponible"].toString())),
                          DataCell(IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              if (producto['tipo'] == 'ingrediente') {
                                editIngredient(producto);
                              } else {
                                editDrink(producto);
                              }
                            },
                          ))
                        ]);
                      }).toList()),
                ))
              ],
            )));
  }
}
