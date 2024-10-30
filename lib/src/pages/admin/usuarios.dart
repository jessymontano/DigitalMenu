import 'package:digital_menu/src/widgets/button.dart';
import 'package:digital_menu/src/widgets/input.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class Usuarios extends StatefulWidget {
  const Usuarios({super.key});

  @override
  State<Usuarios> createState() => _UsuariosState();
}

class _UsuariosState extends State<Usuarios> {
  List<Map<String, dynamic>> _usersList = [];
  bool isEditing = false;
  bool isAdding = false;
  Map<String, dynamic>? selectedItem;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _userNameController;
  late TextEditingController _emailController;
  late String roleValue;
  late TextEditingController _passwordController;

  Future<void> getUsers() async {
    var users = await supabase.from('usuarios').select('*');
    setState(() {
      _usersList = users;
    });
  }

  void editUser(Map<String, dynamic> user) {
    setState(() {
      isEditing = true;
      isAdding = false;
      selectedItem = user;
      _nameController = TextEditingController(text: selectedItem?['nombre']);
      _userNameController =
          TextEditingController(text: selectedItem?['nombre_usuario']);
      _emailController = TextEditingController(text: selectedItem?['correo']);
      roleValue = selectedItem?['rol'];
      _passwordController =
          TextEditingController(text: selectedItem?['contrasena']);
    });
  }

  void addUser() {
    setState(() {
      isEditing = false;
      isAdding = true;
      _nameController = TextEditingController();
      _userNameController = TextEditingController();
      _emailController = TextEditingController();
      roleValue = "usuario";
      _passwordController = TextEditingController();
    });
  }

  void deleteUser(int id) async {
    await supabase.from("usuarios").delete().eq('id_usuario', id);
    getUsers();
    setState(() {
      isEditing = false;
      selectedItem = null;
    });
  }

  void saveChanges(int? id) async {
    if (id != null) {
      await supabase.from("usuarios").update({
        'nombre': _nameController.text,
        'nombre_usuario': _userNameController.text,
        'correo': _emailController.text,
        'rol': roleValue,
        'contrasena': _passwordController.text
      }).eq('id_usuario', id);
    } else {
      await supabase.from("usuarios").insert({
        'nombre': _nameController.text,
        'nombre_usuario': _userNameController.text,
        'correo': _emailController.text,
        'rol': roleValue,
        'contrasena': _passwordController.text
      });
    }
    getUsers();
    setState(() {
      isEditing = false;
      isAdding = false;
      selectedItem = null;
    });
  }

  @override
  void initState() {
    super.initState();
    getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Administrar usuarios"),
          if (!isEditing && !isAdding)
            Button(
              size: const Size(250, 100),
              text: "Agregar usuario",
              onPressed: () {
                addUser();
              },
            )
        ],
      ),
      Expanded(
          child: Row(
        children: [
          Expanded(
              child: SingleChildScrollView(
            child: DataTable(
                columns: const [
                  DataColumn(label: Text("#")),
                  DataColumn(label: Text("Nombre")),
                  DataColumn(label: Text("Tipo de usuario")),
                  DataColumn(label: Text("Estado")),
                  DataColumn(label: Text("Editar"))
                ],
                rows: _usersList.map((usuario) {
                  return DataRow(cells: [
                    DataCell(
                      Text(usuario['id_usuario'].toString()),
                    ),
                    DataCell(Text(usuario['nombre'])),
                    DataCell(Text(usuario["rol"])),
                    DataCell(Text(usuario["estado"])),
                    DataCell(IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        editUser(usuario);
                      },
                    ))
                  ]);
                }).toList()),
          )),
          if (isEditing || isAdding)
            Expanded(
                flex: 1,
                child: Padding(
                    padding: const EdgeInsets.all(50),
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
                                  Text(isEditing
                                      ? 'Editar información de usuario'
                                      : 'Agregar nuevo usuario'),
                                  Input(
                                    controller: _nameController,
                                    hintText: "",
                                    labelText: 'Nombre Completo',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Ingrese un nombre';
                                      }
                                      return null;
                                    },
                                  ),
                                  Input(
                                    controller: _userNameController,
                                    hintText: "",
                                    labelText: 'Usuario',
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Ingrese un nombre de usuario';
                                      }
                                      return null;
                                    },
                                  ),
                                  Input(
                                    controller: _emailController,
                                    hintText: "",
                                    labelText: "Correo",
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Ingrese un correo';
                                      }
                                      return null;
                                    },
                                  ),
                                  Input(
                                    controller: _passwordController,
                                    hintText: "",
                                    labelText: "Contraseña",
                                    obscureText: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Ingrese una contraseña';
                                      } else if (value.length < 6) {
                                        return "La contraseña debe contener al menos 6 caracteres";
                                      }
                                      return null;
                                    },
                                  ),
                                  Text("Tipo de usuario"),
                                  DropdownButton(
                                      value: roleValue,
                                      items: [
                                        DropdownMenuItem(
                                          child: Text("Administrador"),
                                          value: 'admin',
                                        ),
                                        DropdownMenuItem(
                                          child: Text("Usuario"),
                                          value: 'usuario',
                                        )
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          roleValue = value!;
                                        });
                                      }),
                                  if (isAdding)
                                    Button(
                                        size: const Size(250, 100),
                                        text: "Agregar Usuario",
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
                                            size: const Size(200, 100),
                                            text: "Guardar cambios",
                                            onPressed: () {
                                              if (_formKey.currentState
                                                      ?.validate() ??
                                                  false) {
                                                saveChanges(selectedItem?[
                                                    'id_usuario']);
                                              }
                                            }),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Button(
                                            size: const Size(200, 100),
                                            text: "Eliminar Usuario",
                                            onPressed: () {
                                              deleteUser(
                                                  selectedItem?['id_usuario']);
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
