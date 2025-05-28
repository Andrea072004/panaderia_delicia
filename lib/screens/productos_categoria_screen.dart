import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/colors.dart';

class ProductosCategoriaScreen extends StatefulWidget {
  final String categoria;
  const ProductosCategoriaScreen({super.key, required this.categoria});

  @override
  State<ProductosCategoriaScreen> createState() => _ProductosCategoriaScreenState();
}

class _ProductosCategoriaScreenState extends State<ProductosCategoriaScreen> {
  final Map<String, int> cantidades = {};

  void _agregarAlCarrito(Map<String, dynamic> producto, int cantidad) async {
  try {
      final carritoRef = FirebaseFirestore.instance.collection('carrito');

      final existente = await carritoRef
          .where('nombre', isEqualTo: producto['nombre'])
          .limit(1)
          .get();

      if (existente.docs.isNotEmpty) {
        final doc = existente.docs.first;
        final data = doc.data();
        final nuevaCantidad = (data['cantidad'] ?? 1) + cantidad;

        await doc.reference.update({'cantidad': nuevaCantidad});
      } else {
        await carritoRef.add({
          'nombre': producto['nombre'],
          'precio': producto['precio'],
          'imagen': producto['imagen'],
          'cantidad': cantidad,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${producto['nombre']} x$cantidad agregado al carrito')),
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
        stream: widget.categoria == 'todos'
            ? FirebaseFirestore.instance.collection('productos').snapshots()
            : FirebaseFirestore.instance
                .collection('productos')
                .where('categoria', isEqualTo: widget.categoria.toLowerCase())
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar productos'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final productos = snapshot.data!.docs;

          if (productos.isEmpty) {
            return const Center(child: Text('No hay productos en esta categoría'));
          }

          return ListView.builder(
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final producto = productos[index].data() as Map<String, dynamic>;
              final nombre = producto['nombre'];
              cantidades.putIfAbsent(nombre, () => 0);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                            ),
                            backgroundColor: Colors.white,
                            builder: (_) => _DetalleProductoModal(
                              producto: producto,
                              onAgregarCarrito: (p, c) => _agregarAlCarrito(p, c),
                            ),
                          );
                        },
                        child: Row(
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
                              _agregarAlCarrito(producto, 1);
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
      ),
    );
  }
}

class _DetalleProductoModal extends StatefulWidget {
  final Map<String, dynamic> producto;
  final void Function(Map<String, dynamic>, int) onAgregarCarrito;

  const _DetalleProductoModal({
    required this.producto,
    required this.onAgregarCarrito,
  });

  @override
  State<_DetalleProductoModal> createState() => _DetalleProductoModalState();
}

class _DetalleProductoModalState extends State<_DetalleProductoModal> {
  int cantidad = 1;

  @override
  Widget build(BuildContext context) {
    final producto = widget.producto;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 6,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    producto['imagen'],
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                producto['nombre'],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secundario,
                ),
              ),
              const SizedBox(height: 8),
              Text('${producto['precio']} soles',
                  style: const TextStyle(fontSize: 18, color: AppColors.secundario)),
              const SizedBox(height: 12),
              if (producto.containsKey('descripcion'))
                Text(
                  producto['descripcion'],
                  style: const TextStyle(fontSize: 16),
                ),
              const SizedBox(height: 16),
              const Text('Puntuación:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              Row(
                children: List.generate(5, (index) {
                  final puntuacion = producto['puntuacion'] ?? 0;
                  return Icon(
                    index < puntuacion ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  );
                }),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      if (cantidad > 1) setState(() => cantidad--);
                    },
                  ),
                  Text('$cantidad', style: const TextStyle(fontSize: 18)),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {
                      setState(() => cantidad++);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    widget.onAgregarCarrito(producto, cantidad);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Agregar al carrito'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.boton,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
