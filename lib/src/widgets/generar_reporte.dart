import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'dart:html' as html;

import 'package:digital_menu/src/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class Reporte extends StatefulWidget {
  final int id;
  const Reporte({required this.id});

  @override
  State<Reporte> createState() => _ReporteState();
}

class _ReporteState extends State<Reporte> {
  List<dynamic> products = [];
  Map<String, dynamic> order = {};
  Uint8List? _logo;

  Future<void> saveAndOpenPdf() async {
    // Crear el documento PDF
    final pdfData = await buildPdf();
    final fileName = 'pdf';

    final blob = html.Blob([pdfData], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  Future<void> getOrder() async {
    var orderDetails = await supabase
        .from('ordenes')
        .select('*')
        .eq('id_orden', widget.id)
        .limit(1);
    var orderProducts = await supabase
        .rpc('obtener_detalles_orden', params: {'id_orden_input': widget.id});
    setState(() {
      products = orderProducts;
      order = orderDetails[0];
    });
  }

  Future<Uint8List> buildPdf() async {
// Create a PDF document.
    final doc = pw.Document();
    final logoByteData = await rootBundle.load('assets/logo.jpg');

    // Convertir a Uint8List
    final logo = logoByteData.buffer.asUint8List();

    // Asignar a variables
    _logo = logo;

// Add page to the PDF
    doc.addPage(
      pw.MultiPage(
        pageTheme: _buildTheme(
            PdfPageFormat.a4,
            pw.Font.ttf(await rootBundle.load('Roboto-Regular.ttf')),
            pw.Font.ttf(await rootBundle.load('Roboto-Bold.ttf')),
            pw.Font.ttf(await rootBundle.load('Roboto-Italic.ttf'))),
        header: _buildHeader,
        footer: _buildFooter,
        build: (context) => [
          _contentTable(context),
          pw.SizedBox(height: 20),
          _contentFooter(context),
          pw.SizedBox(height: 20),
          _termsAndConditions(context),
        ],
      ),
    );
// Return the PDF file content
    return doc.save();
  }

  pw.Widget _buildHeader(pw.Context context) {
    return pw.Column(
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                children: [
                  pw.Container(
                    height: 50,
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Text(
                      'REPORTE',
                      style: pw.TextStyle(
                        color: PdfColor.fromHex('#1D1D1D'),
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 40,
                      ),
                    ),
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.only(
                        left: 10, top: 10, bottom: 10, right: 10),
                    alignment: pw.Alignment.centerLeft,
                    height: 50,
                    child: pw.DefaultTextStyle(
                      style: pw.TextStyle(
                        color: PdfColors.black,
                        fontSize: 12,
                      ),
                      child: pw.GridView(
                        mainAxisSpacing: 10,
                        crossAxisCount: 2,
                        children: [
                          pw.Text('Número de reporte: '),
                          pw.Text(order['id_orden'].toString()),
                          pw.Text('Fecha: '),
                          pw.Text(DateFormat.yMMMd().format(DateTime.now())),
                          pw.Text('Total: '),
                          pw.Text('\$${order['total'].toString()}')
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 20)
                ],
              ),
            ),
            pw.Expanded(
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Container(
                    alignment: pw.Alignment.topRight,
                    padding: const pw.EdgeInsets.only(bottom: 8, left: 30),
                    height: 72,
                    child: _logo != null
                        ? pw.Image(pw.MemoryImage(_logo!),
                            height: 100, width: 200)
                        : pw.PdfLogo(),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (context.pageNumber > 1) pw.SizedBox(height: 20)
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Expanded(
          flex: 2,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                margin: const pw.EdgeInsets.only(top: 20, bottom: 8),
                child: pw.Text(
                  'Encuéntranos en:',
                  style: pw.TextStyle(
                    color: PdfColor.fromHex('#D40A08'),
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Text(
                'https://multitechsoftware.wixsite.com/home',
                style: const pw.TextStyle(
                  fontSize: 8,
                  lineSpacing: 5,
                  color: PdfColors.blueGrey800,
                ),
              ),
              pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                      top: pw.BorderSide(color: PdfColor.fromHex('#D40A08'))),
                ),
                padding: const pw.EdgeInsets.only(top: 10, bottom: 4),
                child: pw.Text(
                  'Copyright (C) 2024 Multitech',
                  style: pw.TextStyle(
                    fontSize: 12,
                    color: PdfColor.fromHex('#1D1D1D'),
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        pw.Text(
          'Página ${context.pageNumber.toString()}/${context.pagesCount.toString()}',
          style: pw.TextStyle(
            fontSize: 12,
            color: PdfColor.fromHex('#1D1D1D'),
          ),
        ),
      ],
    );
  }

  pw.PageTheme _buildTheme(
      PdfPageFormat pageFormat, pw.Font base, pw.Font bold, pw.Font italic) {
    return pw.PageTheme(
      pageFormat: pageFormat,
      theme: pw.ThemeData.withFont(
        base: base,
        bold: bold,
        italic: italic,
      ),
    );
  }

  pw.Widget _contentFooter(pw.Context context) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 1,
          child: pw.DefaultTextStyle(
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.blueGrey800,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Sub Total:'),
                    pw.Text(
                        ('\$${(order['total'] - -(order['total'] * 0.16)).toStringAsFixed(2)}')),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('IVA e Impuestos:'),
                    pw.Text('\$${order['total'] * 0.16}'),
                  ],
                ),
                pw.Divider(color: PdfColor.fromHex('#D40A08')),
                pw.DefaultTextStyle(
                  style: pw.TextStyle(
                    color: PdfColor.fromHex('#1D1D1D'),
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total:'),
                      pw.Text('\$${order['total'].toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _termsAndConditions(pw.Context context) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Expanded(
          child: pw.Row(
            children: [
              pw.Container(
                margin: const pw.EdgeInsets.only(right: 10),
                height: 70,
                child: pw.Text(
                  'Orden hecha por: ',
                  style: pw.TextStyle(
                    color: PdfColors.blueGrey800,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              pw.Expanded(
                child: pw.Container(
                  height: 70,
                  child: pw.RichText(
                      text: pw.TextSpan(
                          text: '${order['nombre_cliente']}\n',
                          style: pw.TextStyle(
                            color: PdfColors.blueGrey800,
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 12,
                          ),
                          children: const [
                        pw.TextSpan(
                          text: '\n',
                          style: pw.TextStyle(
                            fontSize: 5,
                          ),
                        ),
                      ])),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _contentTable(pw.Context context) {
    const tableHeaders = ['Id', 'Producto', 'Precio', 'Cantidad', 'Total'];

    return pw.TableHelper.fromTextArray(
      border: null,
      cellAlignment: pw.Alignment.centerLeft,
      headerDecoration: pw.BoxDecoration(
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
        color: PdfColors.red,
      ),
      headerHeight: 25,
      cellHeight: 40,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.center,
        4: pw.Alignment.centerRight,
      },
      headerStyle: pw.TextStyle(
        color: PdfColors.white,
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
      ),
      cellStyle: const pw.TextStyle(
        color: PdfColors.blueGrey800,
        fontSize: 10,
      ),
      rowDecoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColors.blueGrey900,
            width: .5,
          ),
        ),
      ),
      headers: tableHeaders,
      data: List<List<String>>.generate(
        products.length,
        (row) => [
          products[row]['id_articulo'].toString(), // Id
          products[row]['nombre_articulo'] ?? '', // Producto
          products[row]['precio'].toString(), // Precio
          products[row]['cantidad'].toString(), // Cantidad
          (products[row]['precio'] * products[row]['cantidad'])
              .toStringAsFixed(2), // Total
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getOrder();
  }

  @override
  Widget build(BuildContext context) {
    return Button(
        text: "Generar Reporte",
        size: Size(200, 100),
        onPressed: () {
          saveAndOpenPdf();
        });
  }
}
