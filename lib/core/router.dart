// router.dart - Configuración de rutas con GoRouter
// Define la estructura de rutas de la app, permitiendo navegación por roles y rutas comunes.
// Para agregar rutas, edita el arreglo 'routes'.
// Todos los métodos, variables y widgets están documentados para facilitar el mantenimiento y la extensión.
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../presentation/cliente/screens/home_screen.dart';
import '../presentation/cliente/screens/login_screen.dart';
import '../presentation/duenio/screens/dashboard_screen.dart';
import '../presentation/admin/screens/admin_home.dart';
import '../presentation/cliente/screens/carrito_screen.dart';
import '../presentation/cliente/screens/perfil_screen.dart';
import '../presentation/common/pages/login_page.dart';
import '../presentation/common/pages/splash_page.dart';
import '../presentation/common/pages/register_page.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) {
        return const LoginPage();
      },
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/cliente',
      builder: (context, state) {
        print('🛣️ Router: Navegando a /cliente - Cargando HomeScreen');
        print('🛣️ Router: Estado de la ruta: ${state.uri}');
        print('🛣️ Router: ⚠️ ⚠️ ⚠️ CARGANDO HOMESCREEN ⚠️ ⚠️ ⚠️');
        return const HomeScreen();
      },
    ),
    GoRoute(
      path: '/cliente/carrito',
      builder: (context, state) {
        print('🛣️ Router: Navegando a /cliente/carrito');
        return const CarritoScreen();
      },
    ),
    GoRoute(
      path: '/cliente/perfil',
      builder: (context, state) {
        print('🛣️ Router: Navegando a /cliente/perfil');
        return const PerfilScreen();
      },
    ),
    GoRoute(
      path: '/duenio',
      builder: (context, state) => const DuenioDashboardScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminHomeScreen(),
    ),
  ],
);
// Fin de router.dart
// Todos los métodos, variables y widgets están documentados para facilitar el mantenimiento y la extensión. 