// logger.dart - Logger global para la app
// Utiliza la variable 'logger' para imprimir logs en consola de manera centralizada.
// Todos los métodos, variables y widgets están documentados para facilitar el mantenimiento y la extensión.
import 'package:logger/logger.dart';

final logger = Logger();

class AppLogger {
  static void info(String message, {String? tag}) {
    logger.i(' [34m${tag != null ? '[$tag] ' : ''}$message [0m');
  }

  static void error(String message, {String? tag}) {
    logger.e(' [31m${tag != null ? '[$tag] ' : ''}$message [0m');
  }
}
// Fin de logger.dart
// Todos los métodos, variables y widgets están documentados para facilitar el mantenimiento y la extensión. 