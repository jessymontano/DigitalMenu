import 'package:digital_menu/src/widgets/calculadora.dart';
import 'package:digital_menu/src/pages/home/home.dart';
import 'package:digital_menu/src/widgets/navbar.dart';
import 'package:flutter/material.dart';
import 'package:digital_menu/src/widgets/input.dart';
import 'package:digital_menu/src/widgets/button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  double cambio = 0;
  late int? userId;

  Future<void> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = prefs.getString('userId')!;
    setState(() {
      userId = int.tryParse(id);
    });
  }

  void calculateChange(String cantidad) {
    final montoRecibido = double.tryParse(cantidad) ?? 0;
    setState(() {
      cambio = montoRecibido - widget.total;
    });
  }

  Future<void> insertOrder() async {
    final orden = await supabase.from('ordenes').insert({
      'total': widget.total,
      'nombre_cliente': _nombreController.text,
      'tipo_pago': tipoPago,
      'id_usuario': userId,
    }).select();
    print(orden);

    for (var producto in widget.currentOrder) {
      print(producto['id_platillo']);
      await Supabase.instance.client.from('detalle_orden').insert({
        'id_orden': orden[0]['id_orden'],
        'id_platillo': producto['id_platillo'] ?? null, // Null si es una bebida
        'id_bebida': producto['id_bebida'] ?? null, // Null si es un platillo
        'cantidad': producto['cantidad'],
        'precio': producto['precio'],
        'tipo': producto['tipo']
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser().then((_) {
      print("userId obtenido: $userId");
    });
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
                    padding: EdgeInsets.all(20),
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
                              style:
                                  TextStyle(color: Colors.white, fontSize: 30),
                            ),
                          ),
                          Form(
                            child: Column(children: [
                              Text("Enviar factura por correo"),
                              Input(
                                  hintText: "",
                                  labelText: "Correo",
                                  controller: _correoController),
                              Input(
                                hintText: "",
                                controller: _nombreController,
                                labelText: "Nombre del cliente",
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
                                    size: Size(200, 100),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Home()));
                                    }),
                                SizedBox(
                                  width: 10,
                                ),
                                Button(
                                  size: Size(200, 100),
                                  onPressed: () async {
                                    await insertOrder();
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Home()));
                                  },
                                  text: "Pagar",
                                ),
                              ]),
                        ]))),
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
        title: Text('Pago'));
  }
}
