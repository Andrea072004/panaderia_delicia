import 'package:flutter/material.dart';
import '../theme/colors.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: AppColors.principal,
      ),
      backgroundColor: AppColors.fondoClaro,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/usuario.png'), // usa tu propia imagen o ícono
            ),
            const SizedBox(height: 16),
            const Text(
              'Andrea Ramírez',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.secundario,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'andrearamirez@email.com',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.secundario,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.secundario),
              title: const Text('Editar perfil'),
              onTap: () {
                // Acción futura
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.secundario),
              title: const Text('Cerrar sesión'),
              onTap: () {
                // Acción de logout
              },
            ),
          ],
        ),
      ),
    );
  }
}
