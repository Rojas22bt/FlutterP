import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../provider/user_provider.dart'; 
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String correo = '';
  String password = '';

  void _login() async {
  if (_formKey.currentState!.validate()) {
    final userData = await AuthService.login(correo, password);

    if (!mounted) return;

    if (userData != null) {
      // ✅ Guardar usuario en Provider
      Provider.of<UserProvider>(context, listen: false).setUser(userData['usuario']);

      // ✅ Obtener y guardar productos activos
      try {
        final productos = await AuthService.obtenerProductosActivos();
        print("✅ Productos activos recibidos:");
        print(productos);

        // Guardar productos en Provider
        Provider.of<UserProvider>(context, listen: false).setProductos(productos.cast<Map<String, dynamic>>());
      } catch (e) {
        print("❌ Error al obtener productos activos: $e");
        // Manejo de errores, por ejemplo, mostrar un mensaje al usuario
      }

      // ✅ Redirigir al dashboard
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Credenciales incorrectas')),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Iniciar Sesión")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Correo'),
                onChanged: (value) => correo = value,
                validator: (value) => value!.isEmpty ? 'Ingrese su correo' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                onChanged: (value) => password = value,
                validator: (value) => value!.isEmpty ? 'Ingrese su contraseña' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Ingresar'),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text("¿No tienes cuenta? Regístrate"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
