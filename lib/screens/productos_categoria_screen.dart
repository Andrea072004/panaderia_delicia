import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/colors.dart';

class ProductosCategoriaScreen extends StatelessWidget {
  final String categoria;

  const ProductosCategoriaScreen({super.key, required this.categoria});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoClaro,
      appBar: AppBar(
        backgroundColor: AppColors.principal,
        title: Text(
          categoria[0].toUpperCase() + categoria.substring(1),
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('productos')
            .where('categoria', isEqualTo: categoria.toLowerCase())
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
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  subtitle: Text('${producto['precio'].toString()} soles'),
                  onTap: () {
                    // Acción al hacer clic (puedes navegar a detalles)
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
