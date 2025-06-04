import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'productos_categoria_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CatalogoScreen extends StatelessWidget {
  const CatalogoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 20),
        const Text(
          'Explora por categoría',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.secundario,
          ),
        ),
        const SizedBox(height: 20),
        // Cards de categorías
        _categoriaCard(context, 'Panes', '🥖', AppColors.boton),
        _categoriaCard(context, 'Pasteles', '🍰', AppColors.acento),
        _categoriaCard(context, 'Tortas', '🎂', AppColors.resalte),
        _categoriaCard(context, 'Bizcochos', '🍪', AppColors.secundario),
        _categoriaCard(context, 'Pies', '🥧', AppColors.principal),
        _categoriaCard(context, 'Todos los productos', '🛍️', Colors.teal),
      ],
    );
  }

  Widget _categoriaCard(BuildContext context, String titulo, String emoji, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        leading: Text(
          emoji,
          style: const TextStyle(fontSize: 28),
        ),
        title: Text(
          titulo,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: color),
        onTap: () {
          String key = titulo.toLowerCase();
          if (titulo == 'Todos los productos') key = 'todos';

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductosCategoriaScreen(categoria: key),
            ),
          );
        },
      ),
    );
  }
}
