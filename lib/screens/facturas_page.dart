import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart'; // para formatear la fecha
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';

class FacturasPage extends StatefulWidget {
  const FacturasPage({super.key});

  @override
  State<FacturasPage> createState() => _FacturasPageState();
}

class _FacturasPageState extends State<FacturasPage> {
  List<Map<String, dynamic>> facturas = [];

  bool cargando = false;

  // Simulación del usuario autenticado
  late String correoUsuario;

  late final String fechaInicio;
  late final String fechaFin;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
    final user = Provider.of<UserProvider>(context, listen: false).user;

    if (user == null) return;

    correoUsuario = user['correo'];

    final DateTime ahora = DateTime.now();
    final DateTime haceDiezDias = ahora.subtract(const Duration(days: 10));
    final DateFormat formatter = DateFormat('yyyy-MM-dd');

    fechaFin = formatter.format(ahora);
    fechaInicio = formatter.format(haceDiezDias);

    cargarFacturas();
  });
  }

  Future<void> cargarFacturas() async {
    setState(() => cargando = true);
    final uri = Uri.parse(
      'https://web-production-ab6a3.up.railway.app/api/venta/obtener-comprobante-usuario',
    );
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "correo": correoUsuario,
        "fecha_inicio": fechaInicio,
        "fecha_fin": fechaFin,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final comprobantes = data['comprobantes'] as List;

      setState(() {
        facturas =
            comprobantes.map((c) {
              final items =
                  [
                    ...(c['detalles_productos'] ?? []),
                    ...(c['detalles_ofertas'] ?? []),
                  ].map((d) {
                    return {
                      "descripcion": d['producto'] ?? d['oferta'],
                      "cantidad": d['cantidad'],
                      "precio": d['precio_unitario'] ?? d['precio_oferta'],
                    };
                  }).toList();

              return {
                "fecha": c['fecha'],
                "documento_usuario": c['documento_usuario'],
                "nombre": data['nombre'],
                "precio_total": c['precio_total'],
                "items": items,
              };
            }).toList();
      });
    } else {
      print('Error al obtener datos: ${response.body}');
    }

    setState(() => cargando = false);
  }

  void _generarPDF(BuildContext context, Map<String, dynamic> factura) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build:
            (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Comprobante de Factura',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text('Cliente: ${factura["nombre"]}'),
                pw.Text('Documento: ${factura["documento_usuario"]}'),
                pw.Text('Fecha: ${factura["fecha"]}'),
                pw.SizedBox(height: 10),
                // ignore: deprecated_member_use
                pw.Table.fromTextArray(
                  headers: ['Descripción', 'Cantidad', 'Precio', 'Subtotal'],
                  data:
                      (factura['items'] as List<Map<String, dynamic>>)
                          .map<List<String>>((Map<String, dynamic> item) {
                            final subtotal = item['cantidad'] * item['precio'];
                            return [
                              item['descripcion'],
                              '${item['cantidad']}',
                              'Bs ${item['precio'].toStringAsFixed(2)}',
                              'Bs ${subtotal.toStringAsFixed(2)}',
                            ];
                          })
                          .toList(),
                ),

                pw.SizedBox(height: 10),
                pw.Text(
                  'Total: Bs ${factura["precio_total"].toStringAsFixed(2)}',
                  style: pw.TextStyle(fontSize: 18),
                ),
              ],
            ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Facturas')),
      body:
          cargando
              ? const Center(child: CircularProgressIndicator())
              : facturas.isEmpty
              ? const Center(child: Text("No hay facturas disponibles"))
              : ListView.builder(
                itemCount: facturas.length,
                itemBuilder: (context, index) {
                  final factura = facturas[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: ListTile(
                      title: Text(
                        'Doc: ${factura["documento_usuario"]} - Total: Bs ${factura["precio_total"]}',
                      ),
                      subtitle: Text('Fecha: ${factura["fecha"]}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.picture_as_pdf),
                        onPressed: () => _generarPDF(context, factura),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
