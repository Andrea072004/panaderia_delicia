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
  String searchQuery = ''; // Variable para almacenar la búsqueda
  TextEditingController searchController = TextEditingController(); // Controlador para la barra de búsqueda
  
  // Variables para los filtros
  String selectedFilter = 'Sin filtros'; // Filtro por defecto
  String selectedOrder = 'Ordenar por'; // Filtro de orden

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

  // Método para actualizar la cantidad en Firestore al disminuir
  void _disminuirCantidad(Map<String, dynamic> producto) async {
    final carritoRef = FirebaseFirestore.instance.collection('carrito');

    final existente = await carritoRef
        .where('nombre', isEqualTo: producto['nombre'])
        .limit(1)
        .get();

    if (existente.docs.isNotEmpty) {
      final doc = existente.docs.first;
      final data = doc.data();
      final nuevaCantidad = (data['cantidad'] ?? 1) - 1;

      // Si la cantidad es 0 o menor, se elimina el producto
      if (nuevaCantidad <= 0) {
        await doc.reference.delete();
      } else {
        await doc.reference.update({'cantidad': nuevaCantidad});
      }
    }
  }

  // Mostrar la descripción del producto cuando se hace clic en el ícono de detalle
  void _mostrarDescripcion(Map<String, dynamic> producto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(producto['nombre']),
          content: Text(producto['descripcion'] ?? 'Sin descripción'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
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
      body: Column(
        children: [
          // Barra de búsqueda con filtro al costado
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.trim().toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Buscar productos...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Filtro desplegable para precios, popularidad, y orden alfabético
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: DropdownButton<String>(
                    value: selectedFilter,
                    icon: Icon(Icons.filter_list),
                    items: <String>[
                      'Sin filtros', 
                      'Mayor Precio', 
                      'Menor Precio', 
                      'Más Popular', 
                      'Menos Popular', 
                      'Ordenar de A a Z', 
                      'Ordenar de Z a A'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedFilter = newValue!;
                      });
                    },
                    underline: SizedBox(), // Sin línea debajo
                    isExpanded: false,
                  ),
                ),
              ],
            ),
          ),
          // El resto del contenido en un Expanded
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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
                  stream: FirebaseFirestore.instance.collection('productos').snapshots(),
                  builder: (context, productosSnapshot) {
                    if (productosSnapshot.hasError) {
                      return const Center(child: Text('Error al cargar productos'));
                    }

                    if (productosSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final todosLosProductos = productosSnapshot.data!.docs;

                    // Aplicar búsqueda y filtro por categoría si no se está buscando
                    final productosFiltrados = todosLosProductos.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final nombre = data['nombre']?.toString().toLowerCase() ?? '';
                      final coincideBusqueda = searchQuery.isEmpty || nombre.contains(searchQuery);
                      final coincideCategoria = widget.categoria == 'todos'
                          || data['categoria']?.toString().toLowerCase() == widget.categoria.toLowerCase();
                      
                      // Filtrar según el filtro seleccionado
                      if (selectedFilter == 'Mayor Precio') {
                        return coincideBusqueda && coincideCategoria;
                      } else if (selectedFilter == 'Menor Precio') {
                        return coincideBusqueda && coincideCategoria;
                      } else if (selectedFilter == 'Más Popular') {
                        return coincideBusqueda && coincideCategoria;
                      } else if (selectedFilter == 'Menos Popular') {
                        return coincideBusqueda && coincideCategoria;
                      }

                      return coincideBusqueda && coincideCategoria;
                    }).toList();

                    // Ordenar alfabéticamente A-Z o Z-A
                    if (selectedFilter == 'Ordenar de A a Z') {
                      productosFiltrados.sort((a, b) {
                        final nombreA = (a.data() as Map<String, dynamic>)['nombre'].toString().toLowerCase();
                        final nombreB = (b.data() as Map<String, dynamic>)['nombre'].toString().toLowerCase();
                        return nombreA.compareTo(nombreB);
                      });
                    } else if (selectedFilter == 'Ordenar de Z a A') {
                      productosFiltrados.sort((a, b) {
                        final nombreA = (a.data() as Map<String, dynamic>)['nombre'].toString().toLowerCase();
                        final nombreB = (b.data() as Map<String, dynamic>)['nombre'].toString().toLowerCase();
                        return nombreB.compareTo(nombreA);
                      });
                    }

                    if (productosFiltrados.isEmpty) {
                      return const Center(child: Text('No se encontraron productos'));
                    }

                    return ListView.builder(
                      itemCount: productosFiltrados.length,
                      itemBuilder: (context, index) {
                        final producto = productosFiltrados[index].data() as Map<String, dynamic>;
                        final nombre = producto['nombre'];
                        final puntuacion = producto['puntuacion'] ?? 0;

                        cantidades.putIfAbsent(nombre, () => 0);

                        return Consumer<CartProvider>( 
                          builder: (context, cart, child) {
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
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
                                        Text(
                                          nombre,
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                        Text('S/.${producto['precio']} soles'),
                                        Row(
                                          children: List.generate(5, (index) {
                                            return Icon(
                                              index < puntuacion ? Icons.star : Icons.star_border,
                                              color: Colors.amber,
                                              size: 18,
                                            );
                                          }),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.info_outline),
                                          onPressed: () => _mostrarDescripcion(producto),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle_outline),
                                          onPressed: () => _disminuirCantidad(producto),
                                        ),
                                        Text('${cantidades[nombre] ?? 0}', style: const TextStyle(fontSize: 16)),
                                        IconButton(
                                          icon: const Icon(Icons.add_circle_outline),
                                          onPressed: () => _agregarAlCarrito(producto),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
