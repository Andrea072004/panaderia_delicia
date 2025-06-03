import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/colors.dart';

class CarritoScreen extends StatelessWidget {
  const CarritoScreen({super.key});

  void _actualizarCantidad(DocumentReference ref, int nuevaCantidad) async {
    if (nuevaCantidad <= 0) {
      await ref.delete(); // Eliminar el producto si la cantidad llega a 0
    } else {
      await ref.update({'cantidad': nuevaCantidad});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoClaro,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('carrito')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar el carrito'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!.docs;

          if (items.isEmpty) {
            return const Center(child: Text('Tu carrito está vacío'));
          }

          double total = 0;
          for (var doc in items) {
            final data = doc.data() as Map<String, dynamic>;
            total += (data['precio'] ?? 0) * (data['cantidad'] ?? 1);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final doc = items[index];
                    final producto = doc.data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            producto['imagen'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(producto['nombre']),
                        subtitle: Text(
                          '${producto['precio']} soles x ${producto['cantidad']}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => _actualizarCantidad(
                                doc.reference,
                                producto['cantidad'] - 1,
                              ),
                            ),
                            Text('${producto['cantidad']}'),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => _actualizarCantidad(
                                doc.reference,
                                producto['cantidad'] + 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${total.toStringAsFixed(2)} soles',
                      style: const TextStyle(fontSize: 18, color: AppColors.boton),
                    ),
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
