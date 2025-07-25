import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificacionesPushService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  
  static final SupabaseClient _client = Supabase.instance.client;

  /// Inicializar las notificaciones locales
  static Future<void> inicializarNotificaciones() async {
    try {
      print('🔄 Inicializando notificaciones locales...');
      
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      await _localNotifications.initialize(initSettings);
      print('✅ Notificaciones locales inicializadas');
    } catch (e) {
      print('❌ Error inicializando notificaciones: $e');
    }
  }

  /// Enviar notificación local al dueño
  static Future<void> enviarNotificacionLocal({
    required String titulo,
    required String mensaje,
    required String duenoId,
    Map<String, dynamic>? datosAdicionales,
  }) async {
    try {
      print('🔄 Enviando notificación local...');
      print('🔄 Título: $titulo');
      print('🔄 Mensaje: $mensaje');
      print('🔄 Dueño ID: $duenoId');

      const androidDetails = AndroidNotificationDetails(
        'puntos_channel',
        'Puntos y Asignaciones',
        channelDescription: 'Notificaciones sobre puntos y asignaciones',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        titulo,
        mensaje,
        notificationDetails,
        payload: datosAdicionales != null ? datosAdicionales.toString() : null,
      );

      print('✅ Notificación local enviada exitosamente');
    } catch (e) {
      print('❌ Error enviando notificación local: $e');
    }
  }

  /// Enviar notificación push a través de Supabase
  static Future<void> enviarNotificacionPush({
    required String duenoId,
    required String titulo,
    required String mensaje,
    required String tipo,
    Map<String, dynamic>? datosAdicionales,
  }) async {
    try {
      print('🔄 Enviando notificación push...');
      print('🔄 Dueño ID: $duenoId');
      print('🔄 Título: $titulo');
      print('🔄 Mensaje: $mensaje');
      print('🔄 Tipo: $tipo');

      // Crear notificación en la base de datos
      await _client.from('notificaciones_sistema').insert({
        'usuario_id': duenoId,
        'tipo': tipo,
        'titulo': titulo,
        'mensaje': mensaje,
        'leida': false,
        'enviada_push': true,
        'created_at': DateTime.now().toIso8601String(),
        'datos_adicionales': datosAdicionales,
      });

      print('✅ Notificación push registrada en BD');

      // Aquí podrías integrar con servicios como Firebase Cloud Messaging
      // o usar las funciones de Supabase para enviar push notifications
      // Por ahora solo registramos en la BD

    } catch (e) {
      print('❌ Error enviando notificación push: $e');
    }
  }

  /// Notificar asignación de puntos
  static Future<void> notificarAsignacionPuntos({
    required String duenoId,
    required String duenoEmail,
    required int puntos,
    required String motivo,
    required String tipoOperacion,
    required String adminEmail,
  }) async {
    try {
      print('🔄 Notificando asignación de puntos...');
      
      final titulo = tipoOperacion == 'agregar' 
          ? 'Puntos Agregados' 
          : 'Puntos Quitados';
      
      final mensaje = tipoOperacion == 'agregar'
          ? 'Se han agregado $puntos puntos a tu cuenta. Motivo: $motivo'
          : 'Se han quitado $puntos puntos de tu cuenta. Motivo: $motivo';

      final datosAdicionales = {
        'dueno_id': duenoId,
        'dueno_email': duenoEmail,
        'puntos': puntos,
        'motivo': motivo,
        'tipo_operacion': tipoOperacion,
        'admin_email': adminEmail,
        'fecha': DateTime.now().toIso8601String(),
      };

      // Enviar notificación local
      await enviarNotificacionLocal(
        titulo: titulo,
        mensaje: mensaje,
        duenoId: duenoId,
        datosAdicionales: datosAdicionales,
      );

      // Enviar notificación push
      await enviarNotificacionPush(
        duenoId: duenoId,
        titulo: titulo,
        mensaje: mensaje,
        tipo: 'asignacion_puntos',
        datosAdicionales: datosAdicionales,
      );

      print('✅ Notificación de asignación enviada exitosamente');
    } catch (e) {
      print('❌ Error notificando asignación: $e');
    }
  }

  /// Notificar puntos bajos
  static Future<void> notificarPuntosBajos({
    required String duenoId,
    required String duenoEmail,
    required int puntosDisponibles,
  }) async {
    try {
      print('🔄 Notificando puntos bajos...');
      
      const titulo = 'Puntos Bajos';
      final mensaje = 'Tienes $puntosDisponibles puntos disponibles. Considera solicitar más puntos.';

      final datosAdicionales = {
        'dueno_id': duenoId,
        'dueno_email': duenoEmail,
        'puntos_disponibles': puntosDisponibles,
        'fecha': DateTime.now().toIso8601String(),
      };

      // Enviar notificación local
      await enviarNotificacionLocal(
        titulo: titulo,
        mensaje: mensaje,
        duenoId: duenoId,
        datosAdicionales: datosAdicionales,
      );

      // Enviar notificación push
      await enviarNotificacionPush(
        duenoId: duenoId,
        titulo: titulo,
        mensaje: mensaje,
        tipo: 'puntos_bajos',
        datosAdicionales: datosAdicionales,
      );

      print('✅ Notificación de puntos bajos enviada');
    } catch (e) {
      print('❌ Error notificando puntos bajos: $e');
    }
  }

  /// Notificar puntos agotados
  static Future<void> notificarPuntosAgotados({
    required String duenoId,
    required String duenoEmail,
  }) async {
    try {
      print('🔄 Notificando puntos agotados...');
      
      const titulo = 'Puntos Agotados';
      const mensaje = 'No tienes puntos disponibles. Contacta al administrador.';

      final datosAdicionales = {
        'dueno_id': duenoId,
        'dueno_email': duenoEmail,
        'fecha': DateTime.now().toIso8601String(),
      };

      // Enviar notificación local
      await enviarNotificacionLocal(
        titulo: titulo,
        mensaje: mensaje,
        duenoId: duenoId,
        datosAdicionales: datosAdicionales,
      );

      // Enviar notificación push
      await enviarNotificacionPush(
        duenoId: duenoId,
        titulo: titulo,
        mensaje: mensaje,
        tipo: 'puntos_agotados',
        datosAdicionales: datosAdicionales,
      );

      print('✅ Notificación de puntos agotados enviada');
    } catch (e) {
      print('❌ Error notificando puntos agotados: $e');
    }
  }

  /// Verificar y notificar puntos bajos/agotados
  static Future<void> verificarYNotificarPuntos({
    required String duenoId,
    required String duenoEmail,
    required int puntosDisponibles,
  }) async {
    try {
      print('🔄 Verificando puntos para notificaciones...');
      print('🔄 Puntos disponibles: $puntosDisponibles');

      if (puntosDisponibles <= 0) {
        print('🔄 Puntos agotados, enviando notificación...');
        await notificarPuntosAgotados(
          duenoId: duenoId,
          duenoEmail: duenoEmail,
        );
      } else if (puntosDisponibles <= 50) {
        print('🔄 Puntos bajos, enviando notificación...');
        await notificarPuntosBajos(
          duenoId: duenoId,
          duenoEmail: duenoEmail,
          puntosDisponibles: puntosDisponibles,
        );
      } else {
        print('🔄 Puntos suficientes, no se requiere notificación');
      }
    } catch (e) {
      print('❌ Error verificando puntos: $e');
    }
  }
} 