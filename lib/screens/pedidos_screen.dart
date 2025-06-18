import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/colors.dart';
import 'package:intl/intl.dart';

class PedidosScreen extends StatelessWidget {
  const PedidosScreen({super.key});

  String get userId => FirebaseAuth.instance.currentUser?.uid ?? 'invitado';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoClaro,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(userId)
            .collection('carrito')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar el historial.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No tienes productos registrados aún.'));
          }

          final compras = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: compras.length,
            itemBuilder: (context, index) {
              final data = compras[index].data() as Map<String, dynamic>;
              final nombre = data['nombre'] ?? 'Producto';
              final cantidad = data['cantidad'] ?? 1;
              final precio = data['precio'] ?? 0.0;
              final imagen = data['imagen'] ?? '';
              final timestamp = data['timestamp'] as Timestamp?;
              final fecha = timestamp != null
                  ? DateFormat('dd/MM/yyyy hh:mm a').format(timestamp.toDate())
                  : 'Fecha no disponible';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imagen,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cantidad: $cantidad'),
                      Text('Fecha: $fecha'),
                    ],
                  ),
                  trailing: Text(
                    'S/.${precio.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.boton),
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
