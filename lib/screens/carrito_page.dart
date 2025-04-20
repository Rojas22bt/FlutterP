import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './carrito_provider.dart';
import '../services/stripepaumentscreen.dart';
import '../services/notificaciones.dart';
import '../provider/user_provider.dart';
import '../services/auth_service.dart';

class CarritoPage extends StatefulWidget {
  const CarritoPage({super.key});

  @override
  State<CarritoPage> createState() => _CarritoPageState();
}

class _CarritoPageState extends State<CarritoPage> {
  String? documentoSeleccionado;
  bool iniciaPuntos = false;

  @override
  Widget build(BuildContext context) {
    final carrito = Provider.of<CarritoProvider>(context);
    final productos = carrito.productosAgrupados;
    final user = Provider.of<UserProvider>(context).user;
    final documentos = user?['documentos'] ?? [];
    final puntos = user?['puntos'] ?? 0;
    final puedeUsarPuntos = puntos >= 10;

    final totalOriginal = carrito.total;
    final totalCalculado = iniciaPuntos
        ? totalOriginal - (totalOriginal * (puntos / 100))
        : totalOriginal;

    return Scaffold(
      appBar: AppBar(title: const Text("Carrito")),
      body: productos.isEmpty
          ? const Center(child: Text("No hay productos en el carrito"))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Selecciona un tipo de documento',
                    ),
                    value: documentoSeleccionado,
                    onChanged: (value) {
                      setState(() {
                        documentoSeleccionado = value;
                      });
                    },
                    items: documentos.map<DropdownMenuItem<String>>((doc) {
                      return DropdownMenuItem<String>(
                        value: doc['numero'].toString(),
                        child: Text(doc['documento__descripcion']),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Puntos disponibles:"),
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: TextFormField(
                          readOnly: true,
                          initialValue: puntos.toString(),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor:
                                puntos < 10 ? Colors.red[100] : Colors.green[100],
                            border: OutlineInputBorder(),
                          ),
                          style: TextStyle(
                            color:
                                puntos < 10 ? Colors.red[900] : Colors.green[900],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (puedeUsarPuntos)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                iniciaPuntos ? Colors.green : Colors.transparent,
                            side: const BorderSide(color: Colors.green),
                            foregroundColor:
                                iniciaPuntos ? Colors.white : Colors.green,
                          ),
                          onPressed: () {
                            setState(() {
                              iniciaPuntos = !iniciaPuntos;
                            });
                          },
                          child: Text(iniciaPuntos
                              ? '✅ Usando puntos para descuento'
                              : 'Usar puntos en este pago'),
                        )
                      else
                        const Text(
                          "Necesitas al menos 10 puntos para usarlos.",
                          style: TextStyle(color: Colors.red),
                        )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      children: productos.entries.map((entry) {
                        final id = entry.key;
                        final p = entry.value;
                        final subtotal = p['cantidad'] * p['precio'];

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p['descripcion'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('Precio: \$${p['precio']}'),
                                      Text(
                                        'Subtotal: \$${subtotal.toStringAsFixed(2)}',
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () =>
                                          carrito.decrementarCantidad(id),
                                    ),
                                    Text('${p['cantidad']}'),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () =>
                                          carrito.incrementarCantidad(id),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Total a pagar: \$${totalCalculado.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: carrito.total <= 0 || documentoSeleccionado == null
                          ? null
                          : () async {
                              final result = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StripeCardFormPage(
                                    total: totalCalculado,
                                    onPagoExitoso: () async {
                                      try {
                                        final carritoProvider =
                                            Provider.of<CarritoProvider>(context,
                                                listen: false);
                                        final userProvider =
                                            Provider.of<UserProvider>(context,
                                                listen: false);
                                        final user = userProvider.user;

                                        final productosSeleccionados =
                                            carritoProvider
                                                .productosAgrupados.entries
                                                .map((entry) {
                                          return {
                                            'id': entry.key,
                                            'cantidad': entry.value['cantidad'],
                                          };
                                        }).toList();

                                        final userId = user?['id'];
                                        final now = DateTime.now();
                                        final fecha =
                                            "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

                                        final payload = {
                                          "factura": {
                                            "nit": "12345678",
                                            "descripcion":
                                                "venta de productos varios",
                                            "fecha": fecha,
                                            "precio_unidad": 950,
                                            "precio_total": totalCalculado,
                                            "cod_autorizacion": "ABC-123",
                                            "estado": true,
                                          },
                                          "transaccion": {
                                            "detalle": "Pago con tarjeta",
                                            "metodo_pago": 1,
                                          },
                                          "nota_venta": {
                                            "descripcion":
                                                "Venta realizada en tienda central",
                                            "documento_usuario":
                                                documentoSeleccionado,
                                            "usuario": userId,
                                            "usar_puntos": iniciaPuntos,
                                          },
                                          "productos": productosSeleccionados,
                                        };

                                        print("📦 Payload final a enviar:");
                                        print(payload);

                                        final response = await AuthService
                                            .crearFacturacionRequest(payload);

                                        if (response.statusCode == 201) {
                                          print("✅ Venta exitosa");
                                          carrito.limpiarCarrito();
                                          await mostrarNotificacionFactura();
                                        } else if (response.statusCode == 400) {
                                          final error = response.body;
                                          print("❌ Error de validación: $error");
                                          showDialog(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              title: const Text('Error'),
                                              content: Text(error.toString()),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text('Cerrar'),
                                                ),
                                              ],
                                            ),
                                          );
                                        } else {
                                          print("❌ Error inesperado: ${response.body}");
                                        }

                                        return true;
                                      } catch (e) {
                                        print("❌ Error al crear factura: $e");
                                        return false;
                                      }
                                    },
                                  ),
                                ),
                              );

                              if (result == true) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Compra realizada con éxito'),
                                  ),
                                );
                              }
                            },
                      child: const Text('Pagar con tarjeta'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
