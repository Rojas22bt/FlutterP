import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _formData = {
    'nombre': '',
    'email': '',
    'telefono': '',
    'date': '',
    'genero': '',
    'password': '',
    'nit': '',
    'ci': '',
  };

  bool _isLoading = false;

  Future<void> _register() async {
  if (!_formKey.currentState!.validate()) return;

  // Validar que al menos uno esté presente
  if (_formData['ci']!.trim().isEmpty && _formData['nit']!.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Debes ingresar al menos CI o NIT"),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    final documentos = [];
    if (_formData['ci']!.trim().isNotEmpty) {
      documentos.add({"id": 1, "numero": _formData['ci']});
    }
    if (_formData['nit']!.trim().isNotEmpty) {
      documentos.add({"id": 2, "numero": _formData['nit']});
    }

    final dataToSend = {
      "nombre": _formData['nombre'],
      "correo": _formData['email'],
      "telefono": _formData['telefono'],
      "fecha_nacimiento": _formData['date'],
      "sexo": _formData['genero'],
      "estado": true,
      "password": _formData['password'],
      "rol": 2,
      "documentos": documentos,
    };

    // 👇 Mostrar en consola lo que se está enviando
    print("➡ Enviando datos al backend:");
    print(dataToSend);

    final success = await AuthService.register(dataToSend);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Usuario registrado con éxito'
            : 'Error al registrar'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );

    if (success) Navigator.pop(context);
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 116, 175, 183), Color.fromARGB(255, 255, 255, 255)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Crear Cuenta',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 70, 62, 225),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildTextField('Nombre completo', 'nombre'),
                      _buildTextField('Correo electrónico', 'email'),
                      _buildTextField('Teléfono', 'telefono'),
                      _buildTextField('Fecha de nacimiento (AAAA-MM-DD)', 'date'),
                      _buildTextField('Sexo (M/F)', 'genero'),
                      _buildTextField('Contraseña', 'password', obscure: true),
                      const Divider(height: 30),
                      const Text('Debe ingresar al menos uno: CI o NIT'),
                      _buildTextField('CI', 'ci'),
                      _buildTextField('NIT', 'nit'),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 152, 181, 221),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _isLoading ? null : _register,
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Color.fromARGB(255, 153, 82, 82))
                              : const Text(
                                  'REGISTRARSE',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          '¿Ya tienes una cuenta? Inicia sesión',
                          style: TextStyle(
                            color: Color.fromARGB(255, 1, 15, 13),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String key, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        obscureText: obscure,
        onChanged: (val) => _formData[key] = val,
        validator: (val) =>
            val == null || val.isEmpty ? 'Este campo es obligatorio' : null,
      ),
    );
  }
}
