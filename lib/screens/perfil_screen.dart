import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/colors.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: AppColors.principal,
        elevation: 0,
      ),
      backgroundColor: AppColors.fondoClaro,
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('usuarios').doc(uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No se encontraron datos del usuario'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/usuario.png'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${userData['nombres']} ${userData['apellidos']}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secundario,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${userData['email']}',
                    style: const TextStyle(fontSize: 14, color: AppColors.secundario),
                  ),
                  const SizedBox(height: 24),

                  _categoriaCard(context, 'Editar perfil', Icons.edit, AppColors.acento, userData),
                  _categoriaCard(context, 'Mis Direcciones', Icons.location_on, AppColors.resalte, userData),
                  _categoriaCard(context, 'Cerrar sesión', Icons.logout, AppColors.boton, userData),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _categoriaCard(BuildContext context, String titulo, IconData icon, Color color, Map<String, dynamic> userData) {
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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color),
        ),
        trailing: Icon(Icons.chevron_right, color: color),
        onTap: () {
          if (titulo == 'Editar perfil') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditarPerfilScreen(userData: userData),
              ),
            );
          } else if (titulo == 'Mis Direcciones') {
            // En desarrollo
          } else if (titulo == 'Cerrar sesión') {
            FirebaseAuth.instance.signOut();
            Navigator.pushReplacementNamed(context, '/login');
          }
        },
      ),
    );
  }
}

// ===================== EDITAR PERFIL =====================
class EditarPerfilScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditarPerfilScreen({super.key, required this.userData});

  @override
  _EditarPerfilScreenState createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _emailController;
  late TextEditingController _edadController;
  late TextEditingController _fechaNacimientoController;
  late TextEditingController _sexoController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.userData['nombres']);
    _apellidoController = TextEditingController(text: widget.userData['apellidos']);
    _emailController = TextEditingController(text: widget.userData['email']);
    _edadController = TextEditingController(text: widget.userData['edad'].toString());
    _fechaNacimientoController = TextEditingController(
      text: widget.userData['fechaNacimiento'] != null
          ? widget.userData['fechaNacimiento'].toDate().toString().split(' ')[0]
          : '',
    );
    _sexoController = TextEditingController(text: widget.userData['sexo']);
  }

  void _guardarCambios() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final userDocRef = FirebaseFirestore.instance.collection('usuarios').doc(uid);

    try {
      await userDocRef.update({
        'nombres': _nombreController.text,
        'apellidos': _apellidoController.text,
        'email': _emailController.text,
        'edad': int.tryParse(_edadController.text) ?? 0,
        'fechaNacimiento': Timestamp.fromDate(DateTime.tryParse(_fechaNacimientoController.text) ?? DateTime.now()),
        'sexo': _sexoController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar cambios: $e')),
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
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
        labelStyle: const TextStyle(color: AppColors.secundario),
        filled: true,
        fillColor: AppColors.principal.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.acento),
        ),
      ),
    );
  }
}