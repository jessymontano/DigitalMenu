import 'dart:convert';

import 'package:digital_menu/src/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Respaldos extends StatefulWidget {
  @override
  State<Respaldos> createState() => _RespaldosState();
}

class _RespaldosState extends State<Respaldos> {
  bool _switchValue = false;
  List<Map<String, String>> backups = [];

  @override
  void initState() {
    super.initState();
    fetchBackups();
  }

  Future<http.Response> backupDatabase() {
    return http.post(Uri.parse("https://arrozzz.pro/api/crear-backup"));
  }

  Future<void> fetchBackups() async {
    final response =
        await http.post(Uri.parse("https://arrozzz.pro/api/ver-backups"));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<String> fileList = List<String>.from(data["files"]);

      List<Map<String, String>> parsedBackups = fileList.map((filename) {
        String dateTime =
            filename.replaceAll("backup-", "").replaceAll(".dump", "");
        List<String> parts = dateTime.split("T");
        String date = parts[0];
        String time = parts[1].split(".")[0].replaceAll("-", ":");

        return {"fileName": filename, "date": date, "time": time};
      }).toList();
      setState(() {
        backups = parsedBackups;
      });
    } else {
      print(jsonDecode(response.body));
    }
  }

  void restoreBackup(String fileName) async {
    var url = Uri.parse("https://arrozzz.pro/api/recuperar-backup");
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Recuperando respaldo...")));
    var response = await http.post(url, body: jsonEncode({'backup': fileName}));

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Respaldo restaurado correctamente")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(50, 0, 50, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text("RESPALDOS"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [Icon(Icons.save), Text("Respaldo automático")],
                ),
                Switch(
                    value: _switchValue,
                    onChanged: (bool value) {
                      setState(() {
                        _switchValue = value;
                      });
                    }),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [Icon(Icons.save), Text("Respaldo manual")],
                ),
                Button(
                    size: const Size(250, 100),
                    text: "Crear respaldo",
                    onPressed: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Creando respaldo...")));
                      var response = await backupDatabase();
                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Respaldo creado exitosamente.")));
                        await fetchBackups();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Error al crear el respaldo.")));
                      }
                    }),
              ],
            ),
            backups.isEmpty
                ? Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text("Fecha")),
                        DataColumn(label: Text("Hora")),
                        DataColumn(label: Text("Acción"))
                      ],
                      rows: backups.map((backup) {
                        return DataRow(cells: [
                          DataCell(Text(backup["date"]!)),
                          DataCell(Text(backup["time"]!)),
                          DataCell(Button(
                            size: const Size(150, 70),
                            onPressed: () => restoreBackup(backup['fileName']!),
                            text: "Restaurar",
                          ))
                        ]);
                      }).toList(),
                    ),
                  )
          ],
        ));
  }
}
