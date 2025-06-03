import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/colors.dart';

import 'catalogo_screen.dart';
import 'carrito_screen.dart';
import 'pedidos_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    _InicioScreen(),
    CatalogoScreen(),
    CarritoScreen(),
    PedidosScreen(),
  ];

  final List<String> _titles = [
    'Inicio',
    'Catálogo',
    'Mi Carrito',
    'Mis Pedidos',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoClaro,
      appBar: AppBar(
        backgroundColor: AppColors.principal,
        elevation: 0,
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('carrito').snapshots(),
            builder: (context, snapshot) {
              final total = snapshot.data?.docs.length ?? 0;
              return Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 2; // Ir a la pestaña del carrito
                      });
                    },
                  ),
                  if (total > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$total',
                          style: const TextStyle(fontSize: 10, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/perfil');
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.boton,
        unselectedItemColor: AppColors.secundario.withOpacity(0.5),
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Catálogo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Carrito',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Pedidos',
          ),
        ],
      ),
    );
  }
}

class _InicioScreen extends StatelessWidget {
  const _InicioScreen();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.acento.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '👋 ¡Hola, Andrea!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secundario,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '🍞 Bienvenida a Delicia.\nTu lugar para disfrutar dulces momentos ✨',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.secundario,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          '🧁 Productos recientes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.secundario,
          ),
        ),
        const SizedBox(height: 16),
        // Llamamos a Firestore para cargar los productos recientes
        _productosRecientes(),
      ],
    );
  }

  // Método para cargar los productos recientes desde Firestore
  Widget _productosRecientes() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('productos') // Nombre de la colección en Firestore
          .orderBy('timestamp', descending: true) // Ordenamos por el campo 'timestamp' (asegurándonos de que sea reciente)
          .limit(3) // Limitar a los últimos 3 productos recientes (puedes ajustar el número)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error al cargar productos'));
        }

        final productos = snapshot.data!.docs;

        if (productos.isEmpty) {
          return const Center(child: Text('No hay productos recientes'));
        }

        return Column(
          children: productos.map((doc) {
            var producto = doc.data() as Map<String, dynamic>;
            return _productoCard(
              producto['nombre'],
              producto['imagen'] ?? 'assets/images/pan.png', // Ahora usa Image.network para cargar la URL de la imagen
            );
          }).toList(),
        );
      },
    );
  }

  static Widget _productoCard(String nombre, String imgPath) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imgPath, // Usamos Image.network para cargar imágenes desde una URL
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          nombre,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: const Text('Disponible hoy'),
        trailing: const Icon(Icons.chevron_right, color: AppColors.secundario),
        onTap: () {
          // Acción futura: ver detalle del producto
        },
      ),
    );
  }
}
