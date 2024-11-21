import 'package:digital_menu/src/widgets/button.dart';
import 'package:digital_menu/src/widgets/input.dart';
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
  String? uploadedFileName;
  List<Map<String, dynamic>> ingredientes = [];
  List<dynamic> ingredientesSeleccionados = [];
  List<dynamic> ingredientesExistentes = [];
  Map<String, dynamic> selectedIngredient = {};

  Future<void> getMenu() async {
    var platillos = await supabase
        .from('platillos')
        .select('id_platillo, nombre, descripcion, precio, imagen');
    setState(() {
      _menuList = platillos;
    });
  }

  Future<void> getDishIngredients(int idPlatillo) async {
    var resultado = await supabase.rpc('obtener_ingredientes_platillo',
        params: {'id_platillo_input': idPlatillo});
    setState(() {
      ingredientesSeleccionados = resultado;
      ingredientesExistentes = List.from(resultado);
    });
    print(ingredientesSeleccionados);
  }

  Future<void> getIngredients() async {
    var resultado = await supabase.from('ingredientes').select('*');
    setState(() {
      ingredientes = resultado;
    });
    print(ingredientes);
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
    });
  }

  void addElement() {
    setState(() {
      isEditing = false;
      isAdding = true;
      _nameController.text = "";
      _descriptionController.text = "";
      _priceController.text = "";
      ingredientesSeleccionados = [];
    });
  }

  void deleteElement(Map<String, dynamic>? element) async {
    String? imagePath = element?['image'];

    if (element != null && element.containsKey('id_platillo')) {
      if (imagePath != null) {
        await supabase.storage.from('img').remove(['images/$imagePath']);
      }
      await supabase
          .from('ingredientes_por_platillo')
          .delete()
          .eq('id_platillo', element['id_platillo']);
      await supabase
          .from('platillos')
          .delete()
          .eq('id_platillo', element["id_platillo"]);
      getMenu();
      setState(() {
        isAdding = false;
        isEditing = false;
        selectedItem = null;
      });
    }
  }

  void saveChanges(Map<String, dynamic>? element) async {
    if (element != null && element.containsKey('id_platillo')) {
      await supabase.from('platillos').update({
        'nombre': _nameController.text,
        'descripcion': _descriptionController.text.isEmpty
            ? 'Sin descripción'
            : _descriptionController.text,
        'precio': double.tryParse(_priceController.text),
        if (uploadedFileName != null) 'imagen': uploadedFileName,
      }).eq('id_platillo', element['id_platillo']);
    } else {
      await supabase.from('platillos').insert({
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

  Future<void> saveIngredients() async {
    int platilloId = selectedItem?['id_platillo'];
    print(ingredientesSeleccionados);
    print(ingredientesExistentes);
    List<dynamic> ingredientesAgregados = ingredientesSeleccionados
        .where((modificado) => !ingredientesExistentes.any((inicial) =>
            inicial['id_ingrediente'] == modificado['id_ingrediente']))
        .toList();

    List<dynamic> ingredientesEliminados = ingredientesExistentes
        .where((inicial) => !ingredientesSeleccionados.any((modificado) =>
            inicial['id_ingrediente'] == modificado['id_ingrediente']))
        .toList();

    for (var ingrediente in ingredientesAgregados) {
      await supabase.from('ingredientes_por_platillo').insert({
        'id_platillo': platilloId,
        'id_ingrediente': ingrediente['id_ingrediente'],
        'cantidad': ingrediente['cantidad'],
      });
    }

    for (var ingrediente in ingredientesEliminados) {
      await supabase
          .from('ingredientes_por_platillo')
          .delete()
          .eq('id_platillo', platilloId)
          .eq('id_ingrediente', ingrediente['id_ingrediente']);
    }

    for (var modificado in ingredientesSeleccionados) {
      var inicial = ingredientesExistentes.firstWhere(
          (inicial) =>
              inicial['id_ingrediente'] == modificado['id_ingrediente'],
          orElse: () => null);

      if (inicial != null && inicial['cantidad'] != modificado['cantidad']) {
        await supabase
            .from('ingredientes_por_platillo')
            .update({'cantidad': modificado['cantidad']})
            .eq('id_platillo', platilloId)
            .eq('id_ingrediente', modificado['id_ingrediente']);
      }
    }
    setState(() {
      selectedIngredient = {};
      _cantidadController.clear();
    });
    await getDishIngredients(platilloId);
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
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Agregar ingredientes"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Map<String, dynamic>>(
                    hint: const Text("Seleccionar ingrediente"),
                    items: ingredientes.map((ingrediente) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: ingrediente,
                        child: Text(ingrediente['nombre'] ?? "sin nombre"),
                      );
                    }).toList(),
                    onChanged: (value) {
                      print(value);
                      setState(() {
                        selectedIngredient = value!;
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
                      if (selectedIngredient != null &&
                          _cantidadController.text.isNotEmpty) {
                        setState(() {
                          if (selectedIngredient != null) {
                            ingredientesSeleccionados.add({
                              ...selectedIngredient,
                              "cantidad":
                                  int.tryParse(_cantidadController.text),
                            });
                            print(ingredientesSeleccionados);
                          }
                          selectedIngredient =
                              {}; // Limpiar el ingrediente seleccionado
                          _cantidadController
                              .clear(); // Limpiar el campo de cantidad
                        });
                      }
                      Navigator.of(context).pop();
                      showIngredientsModal();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Añadir"),
                    style: ElevatedButton.styleFrom(
                      maximumSize: Size(200, 100),
                      backgroundColor: const Color.fromARGB(255, 212, 10, 8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Ingredientes seleccionados:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        ...ingredientesSeleccionados
                            .where((ingrediente) => ingrediente != null)
                            .map((ingrediente) {
                          return ListTile(
                            title: Text(ingrediente['nombre'] ?? 'sin nombre'),
                            subtitle: Text(
                                "Cantidad: ${ingrediente['cantidad'] ?? '0'} ${ingrediente['unidad_medida'] ?? 'unidades'}"),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  ingredientesSeleccionados.remove(ingrediente);
                                });
                                Navigator.of(context).pop();
                                showIngredientsModal();
                              },
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      selectedIngredient = {};
                      ingredientesExistentes = [];
                      ingredientesSeleccionados = [];
                    });
                  },
                  child: const Text(
                    "Cancelar",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                Button(
                  onPressed: () {
                    saveIngredients();
                    Navigator.of(context).pop();
                  },
                  text: "Guardar",
                  size: Size(200, 100),
                ),
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
                                  SizedBox(
                                    height: 10,
                                  ),
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
                            "#",
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
                              Text(elemento['id_platillo'].toString()),
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
                                getDishIngredients(
                                    selectedItem?['id_platillo']);
                              },
                            ))
                          ]);
                        }).toList()),
                  )),
                ]))));
  }
}
