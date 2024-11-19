import 'package:digital_menu/src/recibo.dart';
import 'package:digital_menu/src/widgets/calculadora.dart';
import 'package:digital_menu/src/pages/home/home.dart';
import 'package:digital_menu/src/widgets/navbar.dart';
import 'package:flutter/material.dart';
import 'package:digital_menu/src/widgets/input.dart';
import 'package:digital_menu/src/widgets/button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

final supabase = Supabase.instance.client;

class Pagos extends StatefulWidget {
  final num total;
  final List<Map<String, dynamic>> currentOrder;
  const Pagos({super.key, required this.total, required this.currentOrder});

  @override
  State<Pagos> createState() => _PagosState();
}

class _PagosState extends State<Pagos> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  String tipoPago = "efectivo";
  double cantidadPagada = 0;
  double cambio = 0;
  late int? userId;
  late String? userName;

  Future<void> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = prefs.getString('userId')!;
    String name = prefs.getString('name')!;
    setState(() {
      userId = int.tryParse(id);
      userName = name;
    });
  }

  Future<void> getCurrentOrder() async {
    var order = [];
    for (var articulo in widget.currentOrder) {
      if (articulo['id_platillo'] != null) {
        var nombre = await supabase
            .from('platillos')
            .select('nombre')
            .eq('id_platillo', articulo['id_articulo']);
        order.add({
          'nombre_articulo': nombre,
          'cantidad': articulo['cantidad'],
          'precio': articulo['precio']
        });
      } else {
        var nombre = await supabase
            .from('bebidas')
            .select('nombre')
            .eq('id_bebida', articulo['id_articulo']);
        order.add({
          'nombre_articulo': nombre,
          'cantidad': articulo['cantidad'],
          'precio': articulo['precio']
        });
      }
    }
  }

  void calculateChange(String cantidad) {
    final montoRecibido = double.tryParse(cantidad) ?? 0;
    setState(() {
      cambio = montoRecibido - widget.total;
      cantidadPagada = double.tryParse(cantidad) ?? 0;
    });
  }

  Future<void> insertOrder() async {
    final orden = await supabase.from('ordenes').insert({
      'total': widget.total,
      'nombre_cliente': _nombreController.text,
      'tipo_pago': tipoPago,
      'id_usuario': userId,
    }).select();

    for (var producto in widget.currentOrder) {
      await Supabase.instance.client.from('detalle_orden').insert({
        'id_orden': orden[0]['id_orden'],
        'id_platillo': producto['id_platillo'] ?? null, // Null si es una bebida
        'id_bebida': producto['id_bebida'] ?? null, // Null si es un platillo
        'cantidad': producto['cantidad'],
        'precio': producto['precio'],
        'tipo': producto['tipo']
      });
    }
    if (_correoController.text.isNotEmpty) {}
  }

  Future<void> sendEmail() async {
    var pdf = await generarRecibo({
      'total': widget.total,
      'nombre_cliente': _nombreController.text,
      'tipo_pago': tipoPago,
      'monto_recibido': cantidadPagada,
      'cambio': cambio,
      'nombre_empleado': userName,
      'fecha': DateTime.now().toIso8601String()
    }, widget.currentOrder);

    String pdfBase64 = base64Encode(pdf);
    var url = Uri.parse("http://arrozzz.pro/api/enviar-email");

    var request =
        jsonEncode({'pdfFile': pdfBase64, 'email': _correoController.text});

    var response = await http.post(url, body: request);

    if (response.statusCode == 200) {
      print('correo enviado');
    } else {
      print("error" + response.body);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return NavBar(
        body: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
                flex: 2,
                child: Padding(
                    padding: EdgeInsets.fromLTRB(50, 20, 20, 20),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            height: 70,
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(15)),
                            child: Text(
                              "Total a pagar: \$${widget.total}",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Form(
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                    "Enviar ticket por correo",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24),
                                  ),
                                  Input(
                                      hintText: "",
                                      labelText: "Correo",
                                      controller: _correoController),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Text(
                                    "Nombre del cliente",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24),
                                  ),
                                  Input(
                                    hintText: "",
                                    controller: _nombreController,
                                    labelText: "Nombre del cliente",
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Text(
                                    "Tipo de pago:",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24),
                                  ),
                                  DropdownButton<String>(
                                    value: tipoPago,
                                    items: const [
                                      DropdownMenuItem(
                                        value: 'efectivo',
                                        child: Text("Efectivo"),
                                      ),
                                      DropdownMenuItem(
                                        value: 'tarjeta',
                                        child: Text("Tarjeta"),
                                      )
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        tipoPago = value!;
                                      });
                                    },
                                  ),
                                ]),
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Button(
                                    text: "Cancelar",
                                    size: Size(250, 150),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Home()));
                                    }),
                                SizedBox(
                                  width: 20,
                                ),
                                Button(
                                  size: Size(250, 150),
                                  onPressed: () async {
                                    await insertOrder();

                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Home(
                                                successMessage:
                                                    "Pago realizado correctamente",
                                              )),
                                    );
                                    sendEmail();
                                  },
                                  text: "Pagar",
                                ),
                              ]),
                        ]))),
            SizedBox(width: 50),
            Flexible(
              flex: 1,
              fit: FlexFit.loose,
              child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: PaymentCalculator(
                            onAmountConfirmed: calculateChange,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: 70,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(15)),
                          child: Text(
                            "Cambio: \$${cambio.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ])),
            )
          ],
        ),
        title: Text(
          'Pagar',
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ));
  }
}
