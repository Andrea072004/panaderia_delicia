import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/colors.dart';

class ProductosCategoriaScreen extends StatefulWidget {
  final String categoria;
  final void Function(int index) onNavigateToIndex;

  const ProductosCategoriaScreen({
    super.key,
    required this.categoria,
    required this.onNavigateToIndex,
  });

  @override
  State<ProductosCategoriaScreen> createState() => _ProductosCategoriaScreenState();
}

class _ProductosCategoriaScreenState extends State<ProductosCategoriaScreen> {
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();
  String selectedFilter = 'Sin filtros';

  String get userId => FirebaseAuth.instance.currentUser?.uid ?? 'invitado';

  Future<int> _obtenerCantidadProducto(String nombre) async {
    final cartRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(userId)
        .collection('carrito');

    final query = await cartRef.where('nombre', isEqualTo: nombre).limit(1).get();
    if (query.docs.isNotEmpty) {
      return query.docs.first['cantidad'] ?? 0;
    }
    return 0;
  }

  Future<void> _agregarAlCarrito(Map<String, dynamic> producto) async {
    final cartRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(userId)
        .collection('carrito');

    final query = await cartRef.where('nombre', isEqualTo: producto['nombre']).limit(1).get();
    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      await doc.reference.update({'cantidad': (doc['cantidad'] ?? 1) + 1});
    } else {
      await cartRef.add({
        'nombre': producto['nombre'],
        'precio': producto['precio'],
        'imagen': producto['imagen'],
        'cantidad': 1,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    setState(() {});
  }

  Future<void> _disminuirCantidad(Map<String, dynamic> producto) async {
    final cartRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(userId)
        .collection('carrito');

    final query = await cartRef.where('nombre', isEqualTo: producto['nombre']).limit(1).get();
    if (query.docs.isNotEmpty) {
      final doc = query.docs.first;
      final nuevaCantidad = (doc['cantidad'] ?? 1) - 1;
      if (nuevaCantidad <= 0) {
        await doc.reference.delete();
      } else {
        await doc.reference.update({'cantidad': nuevaCantidad});
      }
    }

    setState(() {});
  }

  void _mostrarDescripcion(Map<String, dynamic> producto) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(producto['nombre']),
        content: Text(producto['descripcion'] ?? 'Sin descripción'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(2, 2)),
        ],
      ),
      child: DropdownButton<String>(
        value: selectedFilter,
        icon: const Icon(Icons.filter_list),
        items: [
          'Sin filtros', 'Mayor Precio', 'Menor Precio',
          'Más Popular', 'Menos Popular',
          'Ordenar de A a Z', 'Ordenar de Z a A'
        ].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
        onChanged: (newValue) => setState(() => selectedFilter = newValue!),
        underline: const SizedBox(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String titulo = widget.categoria[0].toUpperCase() + widget.categoria.substring(1);

    return Scaffold(
      backgroundColor: AppColors.fondoClaro,
      appBar: AppBar(
        backgroundColor: AppColors.principal,
        title: Text(titulo, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => widget.onNavigateToIndex(2), // Navegar a Carrito
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => Navigator.pushNamed(context, '/perfil'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) => setState(() => searchQuery = value.trim().toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Buscar productos...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _buildDropdownFilter(),
              ],
            ),
          ),
          Expanded(child: _buildListaProductos()),
        ],
      ),
    );
  }

  Widget _buildListaProductos() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('productos').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError || snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final productos = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final nombre = data['nombre']?.toString().toLowerCase() ?? '';
          final coincideBusqueda = searchQuery.isEmpty || nombre.contains(searchQuery);
          final coincideCategoria = widget.categoria.toLowerCase() == 'todos' ||
              data['categoria']?.toString().toLowerCase() == widget.categoria.toLowerCase();
          return coincideBusqueda && coincideCategoria;
        }).toList();

        if (selectedFilter == 'Ordenar de A a Z') {
          productos.sort((a, b) => a['nombre'].toString().compareTo(b['nombre'].toString()));
        } else if (selectedFilter == 'Ordenar de Z a A') {
          productos.sort((a, b) => b['nombre'].toString().compareTo(a['nombre'].toString()));
        }

        return ListView.builder(
          itemCount: productos.length,
          itemBuilder: (context, index) {
            final producto = productos[index].data() as Map<String, dynamic>;
            final nombre = producto['nombre'];
            final puntuacion = producto['puntuacion'] ?? 0;
            final descuento = producto['descuento'] ?? 0;
            final precio = (producto['precio'] as num).toDouble();
            final precioFinal = descuento > 0 ? precio - (precio * descuento / 100) : precio;

            return FutureBuilder<int>(
              future: _obtenerCantidadProducto(nombre),
              builder: (context, snapshot) {
                final cantidad = snapshot.data ?? 0;

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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                              if (descuento > 0)
                                Row(
                                  children: [
                                    Text(
                                      'S/.${precio.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'S/.${precioFinal.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Text('S/.${precio.toStringAsFixed(2)} soles'),
                              Row(
                                children: List.generate(5, (i) => Icon(
                                  i < puntuacion ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 18,
                                )),
                              ),
                              IconButton(
                                icon: const Icon(Icons.info_outline),
                                onPressed: () => _mostrarDescripcion(producto),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => _disminuirCantidad(producto),
                            ),
                            Text('$cantidad', style: const TextStyle(fontSize: 16)),
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
  }
}
