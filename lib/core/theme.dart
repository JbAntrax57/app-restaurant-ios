// theme.dart - Configuración de temas claro y oscuro para la app
// Define los temas globales que se pueden personalizar según la identidad visual del proyecto.
// Todos los métodos, variables y widgets están documentados para facilitar el mantenimiento y la extensión.
import 'package:flutter/material.dart';

class AppTheme {
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color clienteColor = Color(0xFF2196F3);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color accentColor = Color(0xFFFFC107);
  static const Color secondaryColor = Color(0xFF4CAF50);
  static const Color primaryColor = Color(0xFF1976D2);
  static const Color successColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFFFA000);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textHintColor = Color(0xFFBDBDBD);
  // Agrega aquí cualquier otro color o propiedad que uses
}

final lightTheme = ThemeData.light();
final darkTheme = ThemeData.dark();
// Fin de theme.dart
// Todos los métodos, variables y widgets están documentados para facilitar el mantenimiento y la extensión. 