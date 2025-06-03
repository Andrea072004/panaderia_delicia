import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../theme/colors.dart';

class ProductosCategoriaScreen extends StatefulWidget {
  final String categoria;
  const ProductosCategoriaScreen({super.key, required this.categoria});

  @override
  State<ProductosCategoriaScreen> createState() => _ProductosCategoriaScreenState();
}

class _ProductosCategoriaScreenState extends State<ProductosCategoriaScreen> {
  final Map<String, int> cantidades = {};

  // Este método actualiza la cantidad de productos en el carrito en tiempo real
  void _agregarAlCarrito(Map<String, dynamic> producto) async {
    try {
      final cart = Provider.of<CartProvider>(context, listen: false);

      // Agregar el producto al carrito en Firestore
      final carritoRef = FirebaseFirestore.instance.collection('carrito');

      // Verificar si el producto ya está en el carrito
      final existente = await carritoRef
          .where('nombre', isEqualTo: producto['nombre'])
          .limit(1)
          .get();

      if (existente.docs.isNotEmpty) {
        final doc = existente.docs.first;
        final data = doc.data();
        final nuevaCantidad = (data['cantidad'] ?? 1) + 1;

        await doc.reference.update({'cantidad': nuevaCantidad});
      } else {
        await carritoRef.add({
          'nombre': producto['nombre'],
          'precio': producto['precio'],
          'imagen': producto['imagen'],
          'cantidad': 1,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      // Mostrar mensaje de confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${producto['nombre']} agregado al carrito')),
      );
    } catch (e) {
      print('❌ Error al agregar al carrito: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoClaro,
      appBar: AppBar(
        backgroundColor: AppColors.principal,
        title: Text(
          widget.categoria[0].toUpperCase() + widget.categoria.substring(1),
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Escuchar los cambios en la colección de productos del carrito
        stream: FirebaseFirestore.instance
            .collection('carrito')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, carritoSnapshot) {
          if (carritoSnapshot.hasError) {
            return const Center(child: Text('Error al cargar el carrito'));
          }

          if (carritoSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final carritoItems = carritoSnapshot.data!.docs;

          // Actualizar el mapa de cantidades en tiempo real
          for (var item in carritoItems) {
            final producto = item.data() as Map<String, dynamic>;
            cantidades[producto['nombre']] = producto['cantidad'];
          }

          return StreamBuilder<QuerySnapshot>(
            stream: widget.categoria == 'todos'
                ? FirebaseFirestore.instance.collection('productos').snapshots()
                : FirebaseFirestore.instance
                    .collection('productos')
                    .where('categoria', isEqualTo: widget.categoria.toLowerCase())
                    .snapshots(),
            builder: (context, productosSnapshot) {
              if (productosSnapshot.hasError) {
                return const Center(child: Text('Error al cargar productos'));
              }
              if (productosSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final productos = productosSnapshot.data!.docs;

              if (productos.isEmpty) {
                return const Center(child: Text('No hay productos en esta categoría'));
              }

              return ListView.builder(
                itemCount: productos.length,
                itemBuilder: (context, index) {
                  final producto = productos[index].data() as Map<String, dynamic>;
                  final nombre = producto['nombre'];

                  // Inicializar cantidad si no se ha encontrado en carrito
                  cantidades.putIfAbsent(nombre, () => 0);

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  producto['imagen'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text('${producto['precio']} soles'),
                                ],
                              ),
                            ],
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  setState(() {
                                    if (cantidades[nombre]! > 0) cantidades[nombre] = cantidades[nombre]! - 1;
                                  });
                                },
                              ),
                              Text('${cantidades[nombre] ?? 0}', style: const TextStyle(fontSize: 16)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () {
                                  setState(() {
                                    cantidades[nombre] = (cantidades[nombre] ?? 0) + 1;
                                  });
                                  _agregarAlCarrito(producto); // Agregar al carrito con los datos completos
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
