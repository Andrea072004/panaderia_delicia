import 'package:flutter/material.dart';
import '../theme/colors.dart';

class ProductoDetalleScreen extends StatelessWidget {
  final Map<String, dynamic> producto;

  const ProductoDetalleScreen({super.key, required this.producto});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoClaro,
      appBar: AppBar(
        title: Text(producto['nombre']),
        backgroundColor: AppColors.principal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  producto['imagen'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              producto['nombre'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.secundario,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Precio: ${producto['precio']} soles',
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.secundario,
              ),
            ),
            const SizedBox(height: 10),
            if (producto.containsKey('descripcion'))
              Text(
                producto['descripcion'],
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 20),
            const Text(
              'Puntuación:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Row(
              children: List.generate(5, (index) {
                final puntuacion = producto['puntuacion'] ?? 0;
                return Icon(
                  index < puntuacion ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
