// localization.dart - Configuración de localización e idiomas soportados
// Define los idiomas disponibles y los delegados de localización para la app.
// Para agregar un nuevo idioma, edita 'supportedLocales' y 'localizationsDelegates'.
// Todos los métodos, variables y widgets están documentados para facilitar el mantenimiento y la extensión.
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

const supportedLocales = [Locale('es'), Locale('en')];
const localizationsDelegates = [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

class AppLocalization {
  static String getString(String key) {
    // Retorna la traducción si existe, si no, retorna el key
    return _localizedStrings[key] ?? key;
  }

  static const Map<String, String> _localizedStrings = {
    'profile': 'Mi Perfil',
    'cart_empty': 'Tu carrito está vacío',
    // Agrega aquí más claves según lo que uses en la app
  };
}
// Fin de localization.dart
// Todos los métodos, variables y widgets están documentados para facilitar el mantenimiento y la extensión. 