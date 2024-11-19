import 'package:digital_menu/src/widgets/button.dart';
import 'package:digital_menu/src/widgets/input.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:digital_menu/src/widgets/image_uploader.dart';
import 'package:side_panel/side_panel.dart';

final supabase = Supabase.instance.client;

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  List<Map<String, dynamic>> _menuList = [];
  final SidePanelController _sidePanelController = SidePanelController();
  bool isEditing = false;
  bool isAdding = false;
  Map<String, dynamic>? selectedItem;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  String typeValue = "platillo";
  String? uploadedFileName;
  List<Map<String, dynamic>> ingredientes = [];
  List<dynamic> ingredientesSeleccionados = [];
  Map<String, dynamic>? selectedIngredient;

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
  }

  Future<void> getDishIngredients(int idPlatillo) async {
    var resultado = await supabase.rpc('obtener_ingredientes_platillo',
        params: {'id_platillo_input': idPlatillo});
    setState(() {
      ingredientesSeleccionados = resultado;
    });
  }

  Future<void> getIngredients() async {
    var resultado = await supabase.from('ingredientes').select('*');
    setState(() {
      ingredientes = resultado;
    });
  }

  String getImageUrl(Map<String, dynamic> elemento) {
    String? imageName = elemento['imagen'];
    if (imageName != null) {
      return "https://kgxonqwulbraeezxplxw.supabase.co/storage/v1/object/public/img/images/$imageName";
    }
    return "https://via.placeholder.com/150";
  }

  void editElement(Map<String, dynamic> element) {
    setState(() {
      isEditing = true;
      isAdding = false;
      selectedItem = element;
      _nameController.text = selectedItem?['nombre'];
      _descriptionController.text = selectedItem?['descripcion'];
      _priceController.text = selectedItem?['precio'].toString() ?? '0';
      typeValue = selectedItem?['tipo'];
    });
  }

  void addElement() {
    setState(() {
      isEditing = false;
      isAdding = true;
      _nameController.text = "";
      _descriptionController.text = "";
      _priceController.text = "";
      typeValue = "platillo";
    });
  }

  void deleteElement(Map<String, dynamic>? element) async {
    String tipo = isAdding ? typeValue : element?['tipo'] ?? '';
    String databaseName = tipo == 'platillo' ? 'platillos' : 'bebidas';
    String? imagePath = element?['image'];

    if (element != null && element.containsKey('id_$tipo')) {
      if (imagePath != null) {
        await supabase.storage.from('img').remove(['images/$imagePath']);
      }
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

  void addIngredient() {
    if (selectedIngredient != null && _cantidadController.text.isNotEmpty) {
      setState(() {
        ingredientesSeleccionados.add({
          "id_platillo": selectedItem?['id_platillo'],
          'id_ingrediente': selectedIngredient?['id_ingrediente'],
          'nombre': selectedIngredient?['nombre'],
          'unidad_medida': selectedIngredient?['unidad_medida'],
          "cantidad": int.tryParse(_cantidadController.text),
        });
        selectedIngredient = null;
        _cantidadController.clear();
      });
    }
  }

  void removeIngredient(int index) {
    setState(() {
      ingredientesSeleccionados.removeAt(index);
    });
  }

  void confirmIngredients() {
    print("Lista de ingredientes confirmada: $ingredientesSeleccionados");
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
    getIngredients();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void showIngredientsModal() {
      getDishIngredients(selectedItem?['id_platillo']);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Agregar ingredientes"),
              content: Column(
                children: [
                  DropdownButtonFormField(
                      items: ingredientes
                          .map((ingrediente) => DropdownMenuItem(
                              value: ingrediente,
                              child: Text(ingrediente['nombre'])))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedIngredient = value;
                        });
                      }),
                  Row(
                    children: [
                      Input(
                          hintText: "",
                          labelText: "Cantidad",
                          controller: _cantidadController),
                      IconButton(
                          onPressed: () {
                            addIngredient();
                          },
                          icon: Icon(Icons.check_box))
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: ListView.builder(
                      itemCount: ingredientesSeleccionados.length,
                      itemBuilder: (context, index) {
                        final ingredient = ingredientesSeleccionados[index];
                        return ListTile(
                          title: Text(
                              "${ingredient['nombre']} - ${ingredient['cantidad']} unidades"),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => removeIngredient(index),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                Button(
                    text: "Cancelar",
                    size: Size(200, 100),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
                Button(
                    text: "Guardar",
                    size: Size(200, 100),
                    onPressed: () {
                      confirmIngredients();
                      Navigator.of(context).pop();
                    }),
              ],
            );
          });
    }

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
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                          icon: const Icon(Icons.close)),
                                      SizedBox(
                                        width: 350,
                                      )
                                    ],
                                  ),
                                  Text(
                                    isEditing
                                        ? 'Editar Elemento'
                                        : 'Agregar Elemento',
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
                                      } else if (double.tryParse(value) ==
                                          null) {
                                        return 'El precio debe ser un número';
                                      }
                                      return null;
                                    },
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  const Text(
                                    "Tipo",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  DropdownButton(
                                      value: typeValue,
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'platillo',
                                          child: Text("Platillo"),
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
                                  SizedBox(
                                    height: 10,
                                  ),
                                  if (selectedItem?['tipo'] == 'platillo')
                                    Button(
                                        text: "Agregar ingredientes",
                                        size: Size(250, 100),
                                        onPressed: showIngredientsModal),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  ImageUploader(
                                    onImageUploaded: (fileName) {
                                      setState(() {
                                        uploadedFileName = fileName;
                                      });
                                    },
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  if (isAdding)
                                    Button(
                                        size: const Size(250, 100),
                                        text: "Agregar",
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
                                          MainAxisAlignment.center,
                                      children: [
                                        Button(
                                            size: const Size(200, 100),
                                            text: "Guardar cambios",
                                            onPressed: () {
                                              if (_formKey.currentState
                                                      ?.validate() ??
                                                  false) {
                                                _sidePanelController
                                                    .hideRightPanel();
                                                saveChanges(selectedItem);
                                              }
                                            }),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Button(
                                            size: const Size(200, 100),
                                            text: "Eliminar",
                                            onPressed: () {
                                              _sidePanelController
                                                  .hideRightPanel();
                                              deleteElement(selectedItem);
                                              setState(() {
                                                isEditing = false;
                                                selectedItem = null;
                                              });
                                            })
                                      ],
                                    )
                                ])))
                  ],
                )),
            child: Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Administrar menú",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 26),
                        ),
                        Button(
                            size: const Size(200, 100),
                            text: "Agregar",
                            onPressed: () {
                              _sidePanelController.showRightPanel();
                              addElement();
                            })
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
                            "Tipo",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )),
                          DataColumn(
                              label: Text(
                            "Nombre",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )),
                          DataColumn(
                              label: Text(
                            "Descripción",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )),
                          DataColumn(
                              label: Text(
                            "Precio",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          )),
                          DataColumn(
                              label: Text(
                            "Editar",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ))
                        ],
                        rows: _menuList.map((elemento) {
                          return DataRow(cells: [
                            DataCell(
                              Text(elemento['tipo'].toString()),
                            ),
                            DataCell(Text(elemento['nombre'])),
                            DataCell(Text(
                                elemento["descripcion"] ?? "Sin descripción")),
                            DataCell(Text(elemento["precio"].toString())),
                            DataCell(IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _sidePanelController.showRightPanel();
                                editElement(elemento);
                              },
                            ))
                          ]);
                        }).toList()),
                  )),
                ]))));
  }
}
