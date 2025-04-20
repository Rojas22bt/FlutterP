import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = Provider.of<UserProvider>(context).user;

    // Redirige si no hay usuario (sesión no iniciada)
    if (usuario == null) {
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, '/');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Bienvenido")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Perfil
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(
                  usuario['nombre'] ?? 'Sin nombre',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(usuario['correo'] ?? 'Sin correo'),
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () => Navigator.pushNamed(context, '/perfil'),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Opciones del menú
            Expanded(
              child: ListView(
                children: [
                  _sectionTile(context, 'Compra', Icons.shopping_bag, '/compra'),
                  _sectionTile(context, 'Carrito', Icons.shopping_cart, '/carrito'),
                  _sectionTile(context, 'Facturas', Icons.receipt_long, '/facturas'),
                ],
              ),
            ),

            // Cerrar sesión
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar Sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Provider.of<UserProvider>(context, listen: false).logout();
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTile(BuildContext context, String title, IconData icon, String route) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.pushNamed(context, route),
      ),
    );
  }
}
