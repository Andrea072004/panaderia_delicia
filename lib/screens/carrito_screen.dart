import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/colors.dart';

class CarritoScreen extends StatefulWidget {
  const CarritoScreen({super.key});

  @override
  _CarritoScreenState createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  String tipoEntrega = 'Recoger en tienda';
  double costoEnvio = 0.0;

  final String userId = FirebaseAuth.instance.currentUser?.uid ?? 'invitado';

  void _actualizarCantidad(DocumentReference ref, int nuevaCantidad) async {
    if (nuevaCantidad <= 0) {
      await ref.delete();
    } else {
      await ref.update({'cantidad': nuevaCantidad});
    }
  }

  void _confirmarPedido(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pedido confirmado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoClaro,
      appBar: AppBar(
        backgroundColor: AppColors.principal,
        title: const Text('Mi Carrito', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(userId)
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
          double totalIGV = 0;

          for (var doc in items) {
            final data = doc.data() as Map<String, dynamic>;
            final precioFinal = data['precio'] ?? 0;
            final cantidad = data['cantidad'] ?? 1;
            final precioBase = precioFinal / 1.18;
            final igvProducto = precioBase * 0.18;
            total += precioFinal * cantidad;
            totalIGV += igvProducto * cantidad;
          }

          if (tipoEntrega == 'Envío') {
            costoEnvio = 5.0;
          } else {
            costoEnvio = 0.0;
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final doc = items[index];
                    final producto = doc.data() as Map<String, dynamic>;
                    final precioFinal = producto['precio'] ?? 0;
                    final cantidad = producto['cantidad'] ?? 1;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
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
                        title: Text(
                          producto['nombre'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        subtitle: Text(
                          'S/.${precioFinal} soles x $cantidad',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => _actualizarCantidad(
                                doc.reference,
                                cantidad - 1,
                              ),
                            ),
                            Text('$cantidad'),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => _actualizarCantidad(
                                doc.reference,
                                cantidad + 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Selecciona la opción de entrega:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() => tipoEntrega = 'Recoger en tienda');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: tipoEntrega == 'Recoger en tienda'
                                ? AppColors.boton
                                : Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          child: const Text('Recoger en tienda', style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() => tipoEntrega = 'Envío');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: tipoEntrega == 'Envío'
                                ? AppColors.boton
                                : Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          child: const Text('Envío (S/. 5.00)', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildResumen('Total (sin IGV):', (total - totalIGV)),
              _buildResumen('IGV (18%):', totalIGV),
              _buildResumen('Envío:', costoEnvio),
              _buildResumen('Total a Pagar:', (total + costoEnvio)),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => _confirmarPedido(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.boton,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Confirmar Pedido',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildResumen(String titulo, double valor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text('S/.${valor.toStringAsFixed(2)} soles',
              style: const TextStyle(fontSize: 16, color: AppColors.boton)),
        ],
      ),
    );
  }
}
