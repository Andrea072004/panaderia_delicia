import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../theme/colors.dart';

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
            .collection('pedidos')
            .orderBy('fecha', descending: true) // ← CAMBIO aquí
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar el historial.'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No tienes pedidos registrados aún.'));
          }

          final pedidos = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final data = pedidos[index].data() as Map<String, dynamic>;
              final productos = List<Map<String, dynamic>>.from(data['productos'] ?? []);
              final total = (data['total'] ?? 0).toDouble();
              final igv = (data['igv'] ?? 0).toDouble();
              final tipoEntrega = data['tipoEntrega'] ?? '---';
              final timestamp = data['fecha'] as Timestamp?;
              final fecha = timestamp != null
                  ? DateFormat('dd/MM/yyyy hh:mm a').format(timestamp.toDate())
                  : 'Fecha desconocida';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: ExpansionTile(
                  title: Text('Pedido del $fecha'),
                  subtitle: Text('Total: S/.${total.toStringAsFixed(2)}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tipo de entrega: $tipoEntrega'),
                          const SizedBox(height: 8),
                          ...productos.map((p) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    p['imagen'] ?? '',
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(p['nombre'] ?? ''),
                                subtitle: Text('Cantidad: ${p['cantidad']}'),
                                trailing: Text('S/.${(p['precio'] ?? 0).toStringAsFixed(2)}'),
                              )),
                          const Divider(),
                          Text('IGV: S/.${igv.toStringAsFixed(2)}'),
                          Text('Total con IGV: S/.${total.toStringAsFixed(2)}'),
                          const SizedBox(height: 12),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}