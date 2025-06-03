import 'package:flutter/foundation.dart';

class Producto {
  final String id;
  final String nombre;
  final double precio;
  final String imagen;
  int cantidad;

  Producto({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.imagen,
    this.cantidad = 1,
  });
}

class CartProvider with ChangeNotifier {
  final Map<String, Producto> _items = {};

  Map<String, Producto> get items {
    return {..._items};
  }

  double get total {
    double total = 0;
    _items.forEach((key, producto) {
      total += producto.precio * producto.cantidad;
    });
    return total;
  }

  void agregarProducto(Map<String, dynamic> productoData) {
    final producto = Producto(
      id: productoData['id'],
      nombre: productoData['nombre'],
      precio: productoData['precio'],
      imagen: productoData['imagen'],
    );

    if (_items.containsKey(producto.id)) {
      _items.update(
        producto.id,
        (existingProducto) => Producto(
          id: existingProducto.id,
          nombre: existingProducto.nombre,
          precio: existingProducto.precio,
          imagen: existingProducto.imagen,
          cantidad: existingProducto.cantidad + 1,
        ),
      );
    } else {
      _items.putIfAbsent(producto.id, () => producto);
    }
    notifyListeners();
  }

  void quitarProducto(String id) {
    _items.remove(id);
    notifyListeners();
  }
}
