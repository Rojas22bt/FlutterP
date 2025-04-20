import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class StripeCardFormPage extends StatefulWidget {
  final double total;
  final Future<bool> Function() onPagoExitoso;

  const StripeCardFormPage({
    super.key,
    required this.total,
    required this.onPagoExitoso,
  });

  @override
  State<StripeCardFormPage> createState() => _StripeCardFormPageState();
}

class _StripeCardFormPageState extends State<StripeCardFormPage> {
  bool _loading = false;
  CardFieldInputDetails? _card;
  final _formKey = GlobalKey<FormState>();

  Future<Map<String, dynamic>?> _createPaymentIntent() async {
    try {
      final response = await http.post(
        Uri.parse('https://web-production-ab6a3.up.railway.app/api/venta/crear-pago'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer tu_token_de_autenticacion', // Añade esto si es necesario
        },
        body: jsonEncode({
          'amount': (widget.total).toInt(), // Stripe usa centavos
          'currency': 'usd', // Cambia según tu moneda
          'description': 'Compra de productos',
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Error al crear PaymentIntent: ${response.body}');
      }
    } catch (e) {
      print('Error en _createPaymentIntent: $e');
      rethrow;
    }
  }

  Future<void> _handlePayment() async {
    if (!(_formKey.currentState?.validate() ?? false) || !(_card?.complete ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor completa todos los campos correctamente")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // 1. Crear factura en tu sistema
      final facturaOk = await widget.onPagoExitoso();
      if (!facturaOk) {
        throw Exception('Error al crear la factura');
      }

      // 2. Crear PaymentIntent en tu backend
      final paymentIntent = await _createPaymentIntent();
      final clientSecret = paymentIntent?['clientSecret'];

      if (clientSecret == null) {
        throw Exception('No se recibió clientSecret del servidor');
      }

      // 3. Confirmar el pago con Stripe
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: const BillingDetails(
              email: 'cliente@ejemplo.com', // Puedes obtener esto del usuario
            ),
          ),
        ),
      );

      // 4. Pago exitoso
      Navigator.pop(context, true);
    } on StripeException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de Stripe: ${e.error.localizedMessage}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pago con tarjeta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _loading ? null : () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información de pago',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              if (Platform.isIOS)
                const Text(
                  'Tarjeta de prueba para desarrollo:',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              if (Platform.isIOS)
                const Text('Número: 4242 4242 4242 4242'),
              if (Platform.isIOS)
                const Text('CVC: Cualquier número de 3 dígitos'),
              if (Platform.isIOS)
                const Text('Fecha: Cualquier fecha futura'),
              if (Platform.isIOS) const SizedBox(height: 20),
              
              // Campo para la tarjeta
              CardField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Datos de la tarjeta',
                ),
                onCardChanged: (card) {
                  setState(() => _card = card);
                },
              ),
              const SizedBox(height: 20),
              
              // Total a pagar
              Center(
                child: Text(
                  'Total: \$${widget.total.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 30),
              
              // Botón de pago
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _loading ? null : _handlePayment,
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Realizar pago'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}