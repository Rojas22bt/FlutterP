import 'package:flutter/material.dart';

class CarritoProvider with ChangeNotifier {
  final Map<String, Map<String, dynamic>> _items = {};

  void agregarProducto(String id, String descripcion, double precio) {
    if (_items.containsKey(id)) {
      _items[id]!['cantidad'] += 1;
    } else {
      _items[id] = {
        'descripcion': descripcion,
        'precio': precio,
        'cantidad': 1,
      };
    }
    notifyListeners();
  }

  void incrementarCantidad(String id) {
    if (_items.containsKey(id)) {
      _items[id]!['cantidad'] += 1;
      notifyListeners();
    }
  }

  void decrementarCantidad(String id) {
    if (_items.containsKey(id) && _items[id]!['cantidad'] > 1) {
      _items[id]!['cantidad'] -= 1;
      notifyListeners();
    } else if (_items.containsKey(id) && _items[id]!['cantidad'] == 1) {
      _items.remove(id);
      notifyListeners();
    }
  }

  Map<String, Map<String, dynamic>> get productosAgrupados => _items;

  double get total {
    double total = 0;
    _items.forEach((_, producto) {
      total += producto['precio'] * producto['cantidad'];
    });
    return total;
  }

  void limpiarCarrito() {
    _items.clear();
    notifyListeners();
  }
}
