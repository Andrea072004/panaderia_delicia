import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/colors.dart';

class CarritoScreen extends StatefulWidget {
  const CarritoScreen({super.key});

  @override
  _CarritoScreenState createState() => _CarritoScreenState();
}

class _CarritoScreenState extends State<CarritoScreen> {
  // Variable para almacenar la opción de entrega (envío o recogida)
  String tipoEntrega = 'Recoger en tienda'; // Valor por defecto
  double costoEnvio = 0.0; // Costo adicional por envío

  void _actualizarCantidad(DocumentReference ref, int nuevaCantidad) async {
    if (nuevaCantidad <= 0) {
      await ref.delete(); // Eliminar el producto si la cantidad llega a 0
    } else {
      await ref.update({'cantidad': nuevaCantidad});
    }
  }

  void _confirmarPedido(BuildContext context) {
    // Aquí puedes agregar la lógica para confirmar el pedido
    // Como un resumen del pedido y luego proceder con la compra
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pedido confirmado')),
    );
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
          double totalIGV = 0;

          for (var doc in items) {
            final data = doc.data() as Map<String, dynamic>;
            final precioFinal = data['precio'] ?? 0;
            final cantidad = data['cantidad'] ?? 1;

            // El precio ya incluye el IGV, así que calculamos el valor sin IGV
            final precioBase = precioFinal / 1.18;
            final igvProducto = precioBase * 0.18; // El IGV calculado

            // Sumar al total
            total += precioFinal * cantidad; // El total final incluye el IGV
            totalIGV += igvProducto * cantidad; // Solo para mostrar el IGV acumulado
          }

          // Agregar costo de envío si es necesario
          if (tipoEntrega == 'Envío') {
            costoEnvio = 5.0; // Se agrega S/ 5.00 si es envío
          } else {
            costoEnvio = 0.0; // No hay costo adicional para recogida en tienda
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
                          'S/.${precioFinal} soles x ${cantidad}',
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
              // Opción de Envío o Recogida con botones redondeados
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Selecciona la opción de entrega:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              tipoEntrega = 'Recoger en tienda';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: tipoEntrega == 'Recoger en tienda'
                                ? AppColors.boton
                                : Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12), // Ajusté el tamaño del botón
                          ),
                          child: const Text(
                            'Recoger en tienda',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              tipoEntrega = 'Envío';
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: tipoEntrega == 'Envío'
                                ? AppColors.boton
                                : Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12), // Ajusté el tamaño del botón
                          ),
                          child: const Text(
                            'Envío (S/. 5.00 adicional)',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total (sin IGV):',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'S/.${(total - totalIGV).toStringAsFixed(2)} soles',
                      style: const TextStyle(
                          fontSize: 16, color: AppColors.boton),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'IGV (18%):',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'S/.${totalIGV.toStringAsFixed(2)} soles',
                      style: const TextStyle(
                          fontSize: 16, color: AppColors.boton),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Envío:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'S/.${costoEnvio.toStringAsFixed(2)} soles',
                      style: const TextStyle(
                          fontSize: 16, color: AppColors.boton),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total a Pagar:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'S/.${(total + costoEnvio).toStringAsFixed(2)} soles',
                      style: const TextStyle(
                          fontSize: 16, color: AppColors.boton),
                    ),
                  ],
                ),
              ),
              // Botón de Confirmación de Pedido
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => _confirmarPedido(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.boton, // Cambié 'primary' a 'backgroundColor'
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Confirmar Pedido',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold, // Aumenté el peso de la fuente
                      color: Colors.white, // Color blanco para el texto
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
