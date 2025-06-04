import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Solo Firestore para manejar los datos

import '../theme/colors.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: AppColors.principal,
        elevation: 0, // Remover la sombra para un estilo más limpio
      ),
      backgroundColor: AppColors.fondoClaro,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/usuario.png'), // Usa tu propia imagen o ícono
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

              // Acción para editar perfil
              _categoriaCard(context, 'Editar perfil', Icons.edit, AppColors.acento),

              // Botón Mis Direcciones
              _categoriaCard(context, 'Mis Direcciones', Icons.location_on, AppColors.resalte),

              // Botón Cerrar sesión
              _categoriaCard(context, 'Cerrar sesión', Icons.logout, AppColors.boton),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoriaCard(BuildContext context, String titulo, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        leading: Icon(icon, color: color),
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
          // Acciones para cada botón
          if (titulo == 'Editar perfil') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditarPerfilScreen(),
              ),
            );
          } else if (titulo == 'Mis Direcciones') {
            // Acción para mis direcciones (aún no implementada)
          } else if (titulo == 'Cerrar sesión') {
            // Acción para cerrar sesión (aún no implementada)
          }
        },
      ),
    );
  }
}

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  _EditarPerfilScreenState createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final TextEditingController _nombreController = TextEditingController(text: 'Andrea Ramírez');
  final TextEditingController _apellidoController = TextEditingController(text: 'Ramírez');
  final TextEditingController _emailController = TextEditingController(text: 'andrearamirez@email.com');
  final TextEditingController _edadController = TextEditingController(text: '25');
  final TextEditingController _fechaNacimientoController = TextEditingController(text: '1997-01-01');
  final TextEditingController _sexoController = TextEditingController(text: 'Femenino');
  final TextEditingController _passwordController = TextEditingController(text: 'password'); // Para actualizar la contraseña

  void _guardarCambios() async {
    final userDocRef = FirebaseFirestore.instance.collection('users').doc('user-id'); // Reemplaza 'user-id' con el ID del usuario

    try {
      await userDocRef.update({
        'nombres': _nombreController.text,
        'apellidos': _apellidoController.text,
        'correo': _emailController.text,
        'edad': _edadController.text,
        'fechaNacimiento': _fechaNacimientoController.text,
        'sexo': _sexoController.text,
        'password': _passwordController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado')),
      );

      Navigator.pop(context); // Regresa a la pantalla de perfil
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: AppColors.principal,
        elevation: 0,
      ),
      backgroundColor: AppColors.fondoClaro,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/usuario.png'),
              ),
              const SizedBox(height: 16),
              _buildInputField(_nombreController, 'Nombres'),
              const SizedBox(height: 16),
              _buildInputField(_apellidoController, 'Apellidos'),
              const SizedBox(height: 16),
              _buildInputField(_emailController, 'Correo electrónico'),
              const SizedBox(height: 16),
              _buildInputField(_edadController, 'Edad'),
              const SizedBox(height: 16),
              _buildInputField(_fechaNacimientoController, 'Fecha de Nacimiento'),
              const SizedBox(height: 16),
              _buildInputField(_sexoController, 'Sexo'),
              const SizedBox(height: 16),
              _buildInputField(_passwordController, 'Nueva Contraseña', obscureText: true),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _guardarCambios,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.boton,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Guardar Cambios',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.secundario),
        filled: true,
        fillColor: AppColors.principal.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.secundario),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.acento),
        ),
      ),
    );
  }
}
