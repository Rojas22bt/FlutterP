import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/user_provider.dart';
import './carrito_provider.dart';
import '../services/voicesearchbutton.dart'; // asegúrate de importar tu archivo correctamente

class CompraPage extends StatefulWidget {
  const CompraPage({super.key});

  @override
  State<CompraPage> createState() => _CompraPageState();
}

class _CompraPageState extends State<CompraPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  List<Map<String, dynamic>> _productosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filtrarProductos);
  }

  void _filtrarProductos() {
    setState(() {
      _searchText = _searchController.text.toLowerCase();
    });
  }

  void _actualizarFiltrados(List<Map<String, dynamic>> filtrados) {
    setState(() {
      _productosFiltrados = filtrados;
    });
  }

  void _agregarAlCarrito(Map<String, dynamic> producto) {
    final carrito = Provider.of<CarritoProvider>(context, listen: false);
    carrito.agregarProducto(
      producto['id'].toString(),
      producto['nombre'] ?? 'Sin nombre',
      double.tryParse(producto['precio'].toString()) ?? 0.0,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${producto['nombre']} añadido al carrito'),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productos = Provider.of<UserProvider>(context).productos;

    // Aplica filtro por texto si no hay filtrado por voz
    final listaProductos = _productosFiltrados.isNotEmpty
        ? _productosFiltrados
        : productos.where((producto) {
            final nombre = (producto['nombre'] ?? '').toString().toLowerCase();
            return nombre.contains(_searchText);
          }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Compra')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Buscar producto',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                VoiceSearchButton(
                  onResult: (texto) {
                    _searchController.text = texto;
                    _filtrarProductos();
                  },
                  productos: productos,
                  onFiltrar: _actualizarFiltrados,
                  onAgregar: _agregarAlCarrito,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: listaProductos.isEmpty
                  ? const Center(child: Text('No hay productos disponibles.'))
                  : ListView.builder(
                      itemCount: listaProductos.length,
                      itemBuilder: (_, index) {
                        final producto = listaProductos[index];
                        return ListTile(
                          leading: producto['url'] != null
                              ? Image.network(
                                  producto['url'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.image_not_supported),
                          title: Text(producto['nombre'] ?? 'Sin nombre'),
                          subtitle: Text('Precio: Bs. ${producto['precio'] ?? '0.00'}'),
                          trailing: ElevatedButton(
                            onPressed: () => _agregarAlCarrito(producto),
                            child: const Text('Añadir'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
