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
  Map<String, dynamic>? selectedItem;
  late TextEditingController _nameController;
  late TextEditingController _userNameController;
  late TextEditingController _emailController;
  late TextEditingController _roleController;
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
      selectedItem = user;
      _nameController = TextEditingController(text: selectedItem?['nombre']);
      _userNameController =
          TextEditingController(text: selectedItem?['nombre_usuario']);
      _emailController = TextEditingController(text: selectedItem?['correo']);
      _roleController = TextEditingController(text: selectedItem?['rol']);
      _passwordController =
          TextEditingController(text: selectedItem?['contrasena']);
    });
  }

  void saveChanges(int id) async {
    await supabase.from("usuarios").update({
      'nombre': _nameController.text,
      'nombre_usuario': _userNameController.text,
      'correo': _emailController.text,
      'rol': _roleController.text,
      'contrasena': _passwordController.text
    }).eq('id_usuario', id);
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
          Button(
            text: "Agregar usuario",
            onPressed: () {},
          )
        ],
      ),
      Row(
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
          if (isEditing && selectedItem != null)
            Expanded(
                flex: 1,
                child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Form(
                        child: Row(
                      children: [
                        const VerticalDivider(
                          thickness: 2,
                        ),
                        Column(children: [
                          const Text('Editar información de usuario'),
                          Input(
                            controller: _nameController,
                            hintText: "",
                            labelText: 'Nombre',
                          ),
                          Input(
                            controller: _userNameController,
                            hintText: "",
                            labelText: 'Usuario',
                          ),
                          Input(
                            controller: _emailController,
                            hintText: "",
                            labelText: "Correo",
                          ),
                          Input(
                            controller: _roleController,
                            hintText: "",
                            labelText: "Tipo de usuario",
                          ),
                          Input(
                            controller: _passwordController,
                            hintText: "",
                            labelText: "Contraseña",
                            obscureText: true,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Button(
                                  text: "Guardar cambios",
                                  onPressed: () {
                                    saveChanges(selectedItem?['id_usuario']);
                                    getUsers();
                                    setState(() {
                                      isEditing = false;
                                      selectedItem = null;
                                    });
                                  }),
                              Button(text: "Eliminar Usuario", onPressed: () {})
                            ],
                          )
                        ])
                      ],
                    ))))
        ],
      )
    ]);
  }
}
