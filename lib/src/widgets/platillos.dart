import 'package:flutter/material.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class Platillos extends StatefulWidget {
  const Platillos({super.key});

  @override
  State<Platillos> createState() => _PlatillosState();
}

class _PlatillosState extends State<Platillos> {
  List<Map<String, dynamic>> menuItems = [];

  Future<void> getMenu() async {
    var platillos = await supabase.from('platillos').select('*');
    setState(() {
      menuItems = platillos;
    });
  }

  @override
  void initState() {
    super.initState();
    getMenu();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black,
                ),
                height: 900,
                width: 1000,
                child: Padding(
                    padding: EdgeInsets.all(20),
                    child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 200,
                            childAspectRatio: 3 / 2,
                            crossAxisSpacing: 30,
                            mainAxisSpacing: 20),
                        itemCount: menuItems.length,
                        itemBuilder: (BuildContext context, index) {
                          return Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15)),
                            child: Column(
                              children: [
                                Text(menuItems[index]['nombre'] +
                                    "  \$" +
                                    menuItems[index]['precio'].toString())
                              ],
                            ),
                          );
                        }))))
      ],
    );
  }
}
