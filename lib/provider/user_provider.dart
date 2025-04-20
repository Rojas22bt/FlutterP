import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  Map<String, dynamic>? _user;
  List<Map<String, dynamic>> _productos = []; // ✅ Lista de productos como Map

  Map<String, dynamic>? get user => _user;
  List<Map<String, dynamic>> get productos => _productos;

  void setUser(Map<String, dynamic> userData) {
    _user = userData;
    notifyListeners();
  }

  void setProductos(List<Map<String, dynamic>> productosData) {
    _productos = productosData;
    notifyListeners();
  }

  void logout() {
    _user = null;
    _productos = []; // ✅ limpiar productos al cerrar sesión
    notifyListeners();
  }

  bool get isLoggedIn => _user != null;
}
