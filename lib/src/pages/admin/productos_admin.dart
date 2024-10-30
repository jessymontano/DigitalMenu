import 'package:flutter/material.dart';
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
  bool isEditing = false;
  bool isAdding = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, dynamic>? selectedItem;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _unidadController;
  late TextEditingController _cantidadController;
  late String typeValue;
  String? uploadedFileName;

  void getProducts() async {
    var listaProductos = await supabase.from('productos').select('*');
    setState(() {
      _productsList = listaProductos;
    });
  }

  void editProduct(Map<String, dynamic> producto) {
    setState(() {
      isEditing = true;
      isAdding = false;
      selectedItem = producto;
      _nameController = TextEditingController(text: selectedItem?['nombre']);
      _descriptionController =
          TextEditingController(text: selectedItem?['descripcion']);
      _priceController =
          TextEditingController(text: selectedItem?['precio'].toString());
      typeValue = selectedItem?['categoria'];
      _unidadController =
          TextEditingController(text: selectedItem?['unidad_medida']);
      _cantidadController = TextEditingController(
          text: selectedItem?['cantidad_disponible'].toString());
    });
  }

  void addProduct() {
    setState(() {
      isEditing = false;
      isAdding = true;
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _priceController = TextEditingController();
      typeValue = 'ingrediente';
      _unidadController = TextEditingController();
      _cantidadController = TextEditingController();
    });
  }

  void deleteProduct(Map<String, dynamic>? producto) async {
    String? imagePath = producto?['image'];

    if (producto != null && producto.containsKey('id_producto')) {
      if (imagePath != null) {
        await supabase.storage.from('img').remove(['images/$imagePath']);
      }
      await supabase
          .from('productos')
          .delete()
          .eq('id_producto', producto["id_producto"]);
      getProducts();
      setState(() {
        isAdding = false;
        isEditing = false;
        selectedItem = null;
      });
    }
  }

  void saveChanges(Map<String, dynamic>? producto) async {
    if (producto != null && producto.containsKey('id_producto')) {
      await supabase.from('productos').update({
        'nombre': _nameController.text,
        'descripcion': _descriptionController.text.isEmpty
            ? 'Sin descripción'
            : _descriptionController.text,
        'precio': double.tryParse(_priceController.text),
        if (uploadedFileName != null) 'imagen': uploadedFileName,
        'unidad_medida': _unidadController.text,
        'cantidad_disponible': int.tryParse(_cantidadController.text),
        'categoria': typeValue
      }).eq('id_producto', producto['id_producto']);
    } else {
      await supabase.from('productos').insert({
        'nombre': _nameController.text,
        'descripcion': _descriptionController.text.isEmpty
            ? 'Sin descripción'
            : _descriptionController.text,
        'precio': double.tryParse(_priceController.text),
        if (uploadedFileName != null) 'imagen': uploadedFileName,
        'unidad_medida': _unidadController.text,
        'cantidad_disponible': int.tryParse(_cantidadController.text),
        'categoria': typeValue
      });
    }
    getProducts();
    setState(() {
      isEditing = false;
      isAdding = false;
      selectedItem = null;
    });
  }

  @override
  void initState() {
    super.initState();
    getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Administrar productos"),
          if (!isEditing && !isAdding)
            Button(
              size: Size(200, 150),
              text: "Agregar producto",
              onPressed: () {
                addProduct();
              },
            )
        ],
      ),
      Expanded(
          flex: 3,
          child: Row(
            children: [
              Expanded(
                  child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                    columns: const [
                      DataColumn(label: Text("Categoría")),
                      DataColumn(label: Text("Nombre")),
                      DataColumn(label: Text("Descripción")),
                      DataColumn(label: Text("Precio")),
                      DataColumn(label: Text("Cantidad disponible")),
                      DataColumn(label: Text("Unidad de medida")),
                      DataColumn(label: Text("Editar"))
                    ],
                    rows: _productsList.map((producto) {
                      return DataRow(cells: [
                        DataCell(Text(producto['categoria'])),
                        DataCell(
                          Text(producto['nombre']),
                        ),
                        DataCell(
                            Text(producto['descripcion'] ?? 'Sin descripción')),
                        DataCell(Text(producto["precio"].toString())),
                        DataCell(
                            Text(producto["cantidad_disponible"].toString())),
                        DataCell(Text(producto['unidad_medida'])),
                        DataCell(IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            editProduct(producto);
                          },
                        ))
                      ]);
                    }).toList()),
              )),
              if (isEditing || isAdding)
                Expanded(
                    flex: 1,
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: SingleChildScrollView(
                            child: Form(
                                key: _formKey,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const VerticalDivider(
                                      thickness: 2,
                                    ),
                                    Column(children: [
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    isEditing = false;
                                                    isAdding = false;
                                                    selectedItem = null;
                                                  });
                                                },
                                                icon: Icon(Icons.close)),
                                            Text(isEditing
                                                ? 'Editar información de producto'
                                                : 'Agregar nuevo producto'),
                                          ]),
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
                                      Input(
                                        controller: _priceController,
                                        hintText: "",
                                        labelText: "Precio",
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
                                      ImageUploader(
                                        onImageUploaded: (fileName) {
                                          setState(() {
                                            uploadedFileName = fileName;
                                          });
                                        },
                                      ),
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
                                      const Text("Categoria"),
                                      DropdownButton(
                                          value: typeValue,
                                          items: const [
                                            DropdownMenuItem(
                                              value: 'ingrediente',
                                              child: Text("Ingrediente"),
                                            ),
                                            DropdownMenuItem(
                                              value: 'bebida',
                                              child: Text("Bebida"),
                                            )
                                          ],
                                          onChanged: (value) {
                                            setState(() {
                                              typeValue = value!;
                                            });
                                          }),
                                      if (isAdding)
                                        Button(
                                            size: Size(150, 100),
                                            text: "Agregar Producto",
                                            onPressed: () {
                                              if (_formKey.currentState
                                                      ?.validate() ??
                                                  false) {
                                                saveChanges(null);
                                              }
                                            }),
                                      if (isEditing)
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Button(
                                                size: Size(200, 100),
                                                text: "Guardar cambios",
                                                onPressed: () {
                                                  if (_formKey.currentState
                                                          ?.validate() ??
                                                      false) {
                                                    saveChanges(selectedItem?[
                                                        'id_producto']);
                                                  }
                                                }),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Button(
                                                size: Size(200, 100),
                                                text: "Eliminar Producto",
                                                onPressed: () {
                                                  deleteProduct(selectedItem?[
                                                      'id_producto']);
                                                  setState(() {
                                                    isEditing = false;
                                                    selectedItem = null;
                                                  });
                                                })
                                          ],
                                        )
                                    ])
                                  ],
                                )))))
            ],
          ))
    ]);
  }
}
