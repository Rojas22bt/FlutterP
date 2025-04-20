import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';

class PerfilPage extends StatelessWidget {
  // Quitamos `const` para permitir cambios estructurales
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final usuario = Provider.of<UserProvider>(context).user;

    // Redirigir al login si no hay sesión activa
    if (usuario == null) {
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, '/');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Mi Perfil")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            _dato("Nombre", usuario['nombre']),
            _dato("Correo", usuario['correo']),
            _dato("Teléfono", usuario['telefono'].toString()),
            _dato("Fecha de Nacimiento", usuario['fecha_nacimiento']),
            _dato("Sexo", usuario['sexo']),
            _dato("Rol", usuario['rol']),
            _dato("Puntos", usuario['puntos'].toString()),
            const SizedBox(height: 20),
            if ((usuario['documentos'] as List).isNotEmpty) ...[
              const Text('Documentos:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              for (var doc in usuario['documentos'])
                _dato(doc['documento__descripcion'], doc['numero'].toString()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _dato(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
