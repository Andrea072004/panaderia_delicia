import 'package:flutter/material.dart';
import '../theme/colors.dart';

class PedidoConfirmadoScreen extends StatelessWidget {
  const PedidoConfirmadoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoClaro,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, color: AppColors.boton, size: 100),
            const SizedBox(height: 20),
            const Text(
              '¡Pedido confirmado!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.secundario),
            ),
            const SizedBox(height: 12),
            const Text(
              'Gracias por tu compra.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.boton,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (route)=>false),
              child: const Text('Volver al inicio', style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}
