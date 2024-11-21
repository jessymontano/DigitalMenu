import 'package:digital_menu/src/pages/admin/compras_admin.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class Graficas extends StatefulWidget {
  @override
  _GraficasState createState() => _GraficasState();
}

class _GraficasState extends State<Graficas> {
  String periodo = 'dia';
  List<Map<String, dynamic>> productosPopulares = [];
  List<Map<String, dynamic>> ventasPorDia = [];

  void getPopularProducts() async {
    List<Map<String, dynamic>> products = await supabase
        .rpc('get_top_products_by_period', params: {'periodo': periodo});
    setState(() {
      productosPopulares = products;
    });
  }

  void getSalesPerDay() async {
    List<Map<String, dynamic>> sales =
        await supabase.rpc("get_sales_by_period", params: {'periodo': periodo});
    setState(() {
      ventasPorDia = sales;
    });
    print(ventasPorDia);
  }

  @override
  void initState() {
    super.initState();
    getPopularProducts();
    getSalesPerDay();
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      // Contenido principal
      Expanded(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          Padding(
              padding: EdgeInsets.all(10),
              child: Container(
                width: 300,
                height: 400,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.black,
                ),
                child: ListView(
                  padding: EdgeInsets.all(5),
                  children: [
                    ListTile(
                        contentPadding: EdgeInsets.all(10),
                        leading: const Icon(Icons.calendar_month_outlined),
                        title: const Text(
                          "Día",
                          style: TextStyle(color: Colors.white),
                        ),
                        selected: periodo == 'dia',
                        onTap: () {
                          setState(() {
                            periodo = 'dia';
                          });
                          getPopularProducts();
                          getSalesPerDay();
                        },
                        selectedColor: Colors.red),
                    ListTile(
                        contentPadding: EdgeInsets.all(10),
                        leading: const Icon(Icons.calendar_month_outlined),
                        title: const Text(
                          "Semana",
                          style: TextStyle(color: Colors.white),
                        ),
                        selected: periodo == 'semana',
                        onTap: () {
                          setState(() {
                            periodo = 'semana';
                          });
                          getPopularProducts();
                          getSalesPerDay();
                        },
                        selectedColor: Colors.red),
                    ListTile(
                        contentPadding: EdgeInsets.all(10),
                        leading: const Icon(Icons.calendar_month_outlined),
                        title: const Text(
                          "Mes",
                          style: TextStyle(color: Colors.white),
                        ),
                        selected: periodo == 'mes',
                        onTap: () {
                          setState(() {
                            periodo = 'mes';
                          });
                          getPopularProducts();
                          getSalesPerDay();
                        },
                        selectedColor: Colors.red)
                  ],
                ),
              )),
        ]),
      )),
      Expanded(
        flex: 3,
        child: Row(
          children: [
            Expanded(
                child: Column(children: [
              Text(
                "Platillos más populares",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Expanded(
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: BarChart(
                        BarChartData(
                          barGroups:
                              List.generate(productosPopulares.length, (index) {
                            final item = productosPopulares[index];
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: item['cantidad_total'] ?? 0,
                                  color: Colors.red,
                                ),
                              ],
                            );
                          }),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget:
                                    (double value, TitleMeta meta) {
                                  final index = value.toInt();
                                  if (index < productosPopulares.length) {
                                    return Text(
                                        productosPopulares[index]['nombre']);
                                  }
                                  return Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget:
                                    (double value, TitleMeta meta) {
                                  return Text(value.toString());
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: true),
                        ),
                      )))
            ])),
            Expanded(
                child: Column(
              children: [
                Text(
                  "Ventas por $periodo",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Expanded(
                    child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(ventasPorDia.length, (index) {
                          final item = ventasPorDia[index];
                          double totalVentas = (item['total_ventas']);

                          return FlSpot(index.toDouble(), totalVentas);
                        }),
                        isCurved: false,
                        color: Colors.red,
                      ),
                    ],
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          interval: 1,
                          showTitles: true,
                          getTitlesWidget: (double value, TitleMeta meta) {
                            final index = value.toInt();
                            if (index < ventasPorDia.length) {
                              return Text(ventasPorDia[index]['intervalo']);
                            }
                            return Text('');
                          },
                        ),
                      ),
                    ),
                  ),
                ))
              ],
            ))
          ],
        ),
      )
    ]);
  }
}
