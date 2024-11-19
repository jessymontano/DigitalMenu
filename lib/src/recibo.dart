import 'dart:typed_data';
import 'package:flutter/foundation.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<Uint8List> generarRecibo(
    Map<String, dynamic> orden, List<Map<String, dynamic>> detalleOrden) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Text(
              'ASADERO TACO REAL SAN ÁNGEL',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text('RFC: TSF53984511B'),
            pw.SizedBox(height: 8),
            pw.Text(
              'San Pedro 17, San Angel\nHermosillo, Sonora, CP. 83287\n'
              '\n6624791594',
            ),
            pw.SizedBox(height: 12),

            // Date and Time
            pw.Text('Fecha/Hora: ${orden['fecha']}'),
            pw.Text('Empleado: ${orden['nombre_empleado']}'),
            pw.Text('Cliente: ${orden['nombre_cliente']}'),
            pw.SizedBox(height: 12),

            // Items Table
            pw.TableHelper.fromTextArray(
              headers: ['Cant', 'Descripción', 'Precio U.', 'Total'],
              data: detalleOrden.map((articulo) {
                return [
                  articulo['cantidad'].toStringAsFixed(2),
                  articulo['nombre'],
                  articulo['precio'].toStringAsFixed(2),
                  (articulo['cantidad'] * articulo['precio'])
                      .toStringAsFixed(2),
                ];
              }).toList(),
            ),
            pw.SizedBox(height: 8),

            // Totals
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                    '${detalleOrden.length.toStringAsFixed(2)} Artículo(s)'),
                pw.SizedBox(width: 8),
                pw.Text('Gran Total: ${orden['total'].toStringAsFixed(2)}'),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                    'IVA 16%: ${(orden['total'] * 0.16).toStringAsFixed(2)}'),
              ],
            ),
            pw.SizedBox(height: 12),

            // Payment Information
            pw.Text('Recibido: ${orden['monto_recibido'].toStringAsFixed(2)}'),
            pw.Text('Cambio: ${orden['cambio'].toStringAsFixed(2)}'),
            pw.SizedBox(height: 16),

            // Footer
            pw.Text('¡Gracias por su compra!'),
            pw.SizedBox(height: 8),
            pw.Text('ASADERO TACO REAL SAN ÁNGEL'),
            pw.SizedBox(height: 8),
            pw.Text('https://www.facebook.com/tacorealsanangel/'),
          ],
        );
      },
    ),
  );

  return pdf.save();
}
