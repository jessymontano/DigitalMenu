import 'package:digital_menu/src/widgets/button.dart';
import 'package:digital_menu/src/widgets/input.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:side_panel/side_panel.dart';

final supabase = Supabase.instance.client;

class Usuarios extends StatefulWidget {
  const Usuarios({super.key});

  @override
  State<Usuarios> createState() => _UsuariosState();
}

class _UsuariosState extends State<Usuarios> {
  SidePanelController _sidePanelController = SidePanelController();
  List<Map<String, dynamic>> _usersList = [];
  bool isEditing = false;
  bool isAdding = false;
  Map<String, dynamic>? selectedItem;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _userNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  String roleValue = "usuario";
  TextEditingController _passwordController = TextEditingController();

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
      _nameController.text = selectedItem?['nombre'];
      _userNameController.text = selectedItem?['nombre_usuario'];
      _emailController.text = selectedItem?['correo'];
      roleValue = selectedItem?['rol'];
      _passwordController.text = selectedItem?['contrasena'];
    });
    _sidePanelController.showRightPanel();
  }

  void addUser() {
    setState(() {
      isEditing = false;
      isAdding = true;
      _nameController.text = "";
      _userNameController.text = "";
      _emailController.text = "";
      roleValue = "usuario";
      _passwordController.text = "";
    });
    _sidePanelController.showRightPanel();
  }

  void deleteUser(int id) async {
    await supabase.from("usuarios").delete().eq('id_usuario', id);
    getUsers();
    setState(() {
      isEditing = false;
      selectedItem = null;
    });
    _sidePanelController.hideRightPanel();
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
    _sidePanelController.hideRightPanel();
  }

  @override
  void initState() {
    super.initState();
    getUsers();
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
                      Form(
                          key: _formKey,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                    ),
                                  ],
                                ),
                                Text(
                                  isEditing
                                      ? 'Editar información de usuario'
                                      : 'Agregar nuevo usuario',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
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
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "Tipo de usuario",
                                  style: TextStyle(fontSize: 16),
                                ),
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
                                SizedBox(
                                  height: 10,
                                ),
                                if (isAdding)
                                  Button(
                                      size: const Size(250, 100),
                                      text: "Agregar Usuario",
                                      onPressed: () {
                                        if (_formKey.currentState?.validate() ??
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
                                              saveChanges(
                                                  selectedItem?['id_usuario']);
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
                              ]))
                    ])),
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
                      "Administrar usuarios",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                    ),
                    Button(
                      size: const Size(250, 100),
                      text: "Agregar usuario",
                      onPressed: () {
                        addUser();
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
                            label: Text(
                          "#",
                          style: TextStyle(color: Colors.white),
                        )),
                        DataColumn(
                            label: Text(
                          "Nombre",
                          style: TextStyle(color: Colors.white),
                        )),
                        DataColumn(
                            label: Text(
                          "Tipo de usuario",
                          style: TextStyle(color: Colors.white),
                        )),
                        DataColumn(
                            label: Text(
                          "Estado",
                          style: TextStyle(color: Colors.white),
                        )),
                        DataColumn(
                            label: Text(
                          "Editar",
                          style: TextStyle(color: Colors.white),
                        ))
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
              ],
            ))));
  }
}
