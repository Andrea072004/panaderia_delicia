import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';

import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/perfil_screen.dart';
import 'screens/carrito_screen.dart';
import 'screens/pedidos_screen.dart';
import 'screens/catalogo_screen.dart';
import 'theme/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const PanaderiaDeliciaApp(),
    ),
  );
}

class PanaderiaDeliciaApp extends StatelessWidget {
  const PanaderiaDeliciaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Panadería Delicia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.boton,
        scaffoldBackgroundColor: AppColors.fondoClaro,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: AppColors.boton,
          secondary: AppColors.acento,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.boton,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/perfil': (context) => const PerfilScreen(),
        '/catalogo': (context) => CatalogoScreen(
          onNavigateToIndex: (int index) {
            // Aquí podrías hacer navegación o lógica, si tienes acceso.
            // Por ahora, usa un placeholder si no puedes acceder directamente.
            print("Navegar a índice $index");
          },
        ),
        '/carrito': (context) => const CarritoScreen(),
        '/pedidos': (context) => const PedidosScreen(),
      },
    );
  }
}
