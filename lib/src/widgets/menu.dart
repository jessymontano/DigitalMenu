import 'package:digital_menu/src/widgets/button.dart';
import 'package:digital_menu/src/widgets/input.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:digital_menu/src/widgets/image_uploader.dart';

final supabase = Supabase.instance.client;

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  List<Map<String, dynamic>> _menuList = [];
  bool isEditing = false;
  bool isAdding = false;
  Map<String, dynamic>? selectedItem;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late String typeValue;
  String? uploadedFileName;

  Future<void> getMenu() async {
    var platillos = await supabase
        .from('platillos')
        .select('id_platillo, nombre, descripcion, precio, imagen');
    List<Map<String, dynamic>> platillosConTipo = platillos.map((platillo) {
      return {...platillo, "tipo": "platillo"};
    }).toList();
    var bebidas = await supabase
        .from("bebidas")
        .select("id_bebida, nombre, descripcion, precio, imagen");
    List<Map<String, dynamic>> bebidasConTipo = bebidas.map((bebida) {
      return {...bebida, "tipo": "bebida"};
    }).toList();
    setState(() {
      _menuList = [...platillosConTipo, ...bebidasConTipo];
    });
    print(_menuList);
  }

  void editElement(Map<String, dynamic> element) {
    setState(() {
      isEditing = true;
      isAdding = false;
      selectedItem = element;
      _nameController = TextEditingController(text: selectedItem?['nombre']);
      _descriptionController =
          TextEditingController(text: selectedItem?['descripcion']);
      _priceController =
          TextEditingController(text: selectedItem?['precio'].toString());
      typeValue = selectedItem?['tipo'];
    });
  }

  void addElement() {
    setState(() {
      isEditing = false;
      isAdding = true;
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _priceController = TextEditingController();
      typeValue = "platillo";
    });
  }

  void deleteElement(Map<String, dynamic>? element) async {
    String tipo = isAdding ? typeValue : element?['tipo'] ?? '';
    String databaseName = tipo == 'platillo' ? 'platillos' : 'bebidas';

    if (element != null && element.containsKey('id_$tipo')) {
      await supabase
          .from(databaseName)
          .delete()
          .eq('id_$tipo', element["id_$tipo"]);
      getMenu();
      setState(() {
        isAdding = false;
        isEditing = false;
        selectedItem = null;
      });
    }
  }

  void saveChanges(Map<String, dynamic>? element) async {
    String tipo = isAdding ? typeValue : element?['tipo'] ?? '';
    String databaseName = tipo == 'platillo' ? 'platillos' : 'bebidas';

    if (element != null && element.containsKey('id_$tipo')) {
      await supabase.from(databaseName).update({
        'nombre': _nameController.text,
        'descripcion': _descriptionController.text.isEmpty
            ? 'Sin descripción'
            : _descriptionController.text,
        'precio': double.tryParse(_priceController.text),
        if (uploadedFileName != null) 'imagen': uploadedFileName,
      }).eq('id_$tipo', element['id_$tipo']);
    } else {
      await supabase.from(databaseName).insert({
        'nombre': _nameController.text,
        'descripcion': _descriptionController.text.isEmpty
            ? 'Sin descripción'
            : _descriptionController.text,
        'precio': double.tryParse(_priceController.text),
        if (uploadedFileName != null) 'imagen': uploadedFileName,
      });
    }
    getMenu();
    setState(() {
      isEditing = false;
      isAdding = false;
      selectedItem = null;
    });
  }

  @override
  void initState() {
    super.initState();
    getMenu();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text("Administrar menu"),
        Button(
            text: "Agregar",
            onPressed: () {
              addElement();
            })
      ]),
      Expanded(
          child: Row(children: [
        Expanded(
            child: SingleChildScrollView(
          child: DataTable(
              columns: [
                DataColumn(label: Text("Tipo")),
                DataColumn(label: Text("Nombre")),
                DataColumn(label: Text("Descripción")),
                DataColumn(label: Text("Precio")),
                DataColumn(label: Text("Editar"))
              ],
              rows: _menuList.map((elemento) {
                return DataRow(cells: [
                  DataCell(
                    Text(elemento['tipo'].toString()),
                  ),
                  DataCell(Text(elemento['nombre'])),
                  DataCell(Text(elemento["descripcion"] ?? "Sin descripción")),
                  DataCell(Text(elemento["precio"].toString())),
                  DataCell(IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      editElement(elemento);
                    },
                  ))
                ]);
              }).toList()),
        )),
        if (isAdding || isEditing)
          Expanded(
              child: SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const VerticalDivider(
                      thickness: 2,
                    ),
                    Column(children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                ? 'Editar Elemento'
                                : 'Agregar Elemento'),
                          ]),
                      Input(
                        controller: _nameController,
                        hintText: "",
                        labelText: 'Nombre',
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
                          } else if (double.tryParse(value) == null) {
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
                      Text("Tipo"),
                      DropdownButton(
                          value: typeValue,
                          items: [
                            DropdownMenuItem(
                              child: Text("Platillo"),
                              value: 'platillo',
                            ),
                            DropdownMenuItem(
                              child: Text("Bebida"),
                              value: 'bebida',
                            )
                          ],
                          onChanged: (value) {
                            setState(() {
                              typeValue = value!;
                            });
                          }),
                      if (isAdding)
                        Button(
                            text: "Agregar",
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                saveChanges(null);
                              }
                            }),
                      if (isEditing)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Button(
                                text: "Guardar cambios",
                                onPressed: () {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    saveChanges(selectedItem);
                                  }
                                }),
                            SizedBox(
                              width: 20,
                            ),
                            Button(
                                text: "Eliminar",
                                onPressed: () {
                                  deleteElement(selectedItem);
                                  setState(() {
                                    isEditing = false;
                                    selectedItem = null;
                                  });
                                })
                          ],
                        )
                    ])
                  ],
                )),
          ))
      ]))
    ]);
  }
}
