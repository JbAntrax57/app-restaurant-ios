import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PuntosProvider extends ChangeNotifier {
  bool _isLoading = false;
  Map<String, dynamic>? _estadisticas;
  List<Map<String, dynamic>> _duenosPuntos = [];
  List<Map<String, dynamic>> _notificaciones = [];

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get estadisticas => _estadisticas;
  List<Map<String, dynamic>> get duenosPuntos => _duenosPuntos;
  List<Map<String, dynamic>> get notificaciones => _notificaciones;

  // Consumir puntos al crear un pedido
  Future<bool> consumirPuntosPedido(String duenoId, {int puntosConsumir = 2}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await Supabase.instance.client
          .rpc('consumir_puntos_pedido', params: {
        'p_dueno_id': duenoId,
        'p_puntos_consumir': puntosConsumir,
      });

      // Verificar estado de restaurantes después de consumir puntos
      await _verificarEstadoRestaurantes();

      _isLoading = false;
      notifyListeners();

      return result == true;
    } catch (e) {
      print('Error consumiendo puntos: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Asignar puntos a un dueño
  Future<bool> asignarPuntosDueno(
    String duenoId,
    int puntos,
    String tipoAsignacion,
    String motivo,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) return false;

      final result = await Supabase.instance.client
          .rpc('asignar_puntos_dueno', params: {
        'p_dueno_id': duenoId,
        'p_puntos': puntos,
        'p_tipo_asignacion': tipoAsignacion,
        'p_motivo': motivo,
        'p_admin_id': currentUser.id,
      });

      // Refrescar datos
      await cargarEstadisticas();
      await cargarDuenosPuntos();
      await cargarNotificaciones();

      _isLoading = false;
      notifyListeners();

      return result == true;
    } catch (e) {
      print('Error asignando puntos: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Cargar estadísticas del sistema de puntos
  Future<void> cargarEstadisticas() async {
    try {
      final result = await Supabase.instance.client
          .rpc('obtener_estadisticas_puntos');
      
      if (result != null && result.isNotEmpty) {
        _estadisticas = result[0];
      } else {
        _estadisticas = {
          'total_duenos': 0,
          'duenos_con_puntos': 0,
          'duenos_sin_puntos': 0,
          'total_puntos_asignados': 0,
          'total_puntos_consumidos': 0,
          'total_puntos_disponibles': 0,
        };
      }
      notifyListeners();
    } catch (e) {
      print('Error cargando estadísticas: $e');
      _estadisticas = {
        'total_duenos': 0,
        'duenos_con_puntos': 0,
        'duenos_sin_puntos': 0,
        'total_puntos_asignados': 0,
        'total_puntos_consumidos': 0,
        'total_puntos_disponibles': 0,
      };
      notifyListeners();
    }
  }

  // Cargar lista de dueños con puntos
  Future<void> cargarDuenosPuntos() async {
    try {
      final result = await Supabase.instance.client
          .from('dashboard_puntos')
          .select('*')
          .order('puntos_disponibles', ascending: false);
      
      _duenosPuntos = List<Map<String, dynamic>>.from(result);
      notifyListeners();
    } catch (e) {
      print('Error cargando dueños con puntos: $e');
      _duenosPuntos = [];
      notifyListeners();
    }
  }

  // Cargar notificaciones del sistema
  Future<void> cargarNotificaciones() async {
    try {
      final result = await Supabase.instance.client
          .from('notificaciones_sistema')
          .select('*')
          .order('created_at', ascending: false)
          .limit(20);
      
      _notificaciones = List<Map<String, dynamic>>.from(result);
      notifyListeners();
    } catch (e) {
      print('Error cargando notificaciones: $e');
      _notificaciones = [];
      notifyListeners();
    }
  }

  // Verificar estado de restaurantes basado en puntos
  Future<void> _verificarEstadoRestaurantes() async {
    try {
      await Supabase.instance.client
          .rpc('verificar_estado_restaurantes_por_puntos');
    } catch (e) {
      print('Error verificando estado de restaurantes: $e');
    }
  }

  // Obtener puntos de un dueño específico
  Future<Map<String, dynamic>?> obtenerPuntosDueno(String duenoId) async {
    try {
      final result = await Supabase.instance.client
          .from('sistema_puntos')
          .select('*')
          .eq('dueno_id', duenoId)
          .maybeSingle();
      
      return result;
    } catch (e) {
      print('Error obteniendo puntos del dueño: $e');
      return null;
    }
  }

  // Marcar notificación como leída
  Future<void> marcarNotificacionLeida(String notificacionId) async {
    try {
      await Supabase.instance.client
          .from('notificaciones_sistema')
          .update({'leida': true})
          .eq('id', notificacionId);
      
      // Refrescar notificaciones
      await cargarNotificaciones();
    } catch (e) {
      print('Error marcando notificación como leída: $e');
    }
  }

  // Obtener notificaciones no leídas para un usuario
  Future<List<Map<String, dynamic>>> obtenerNotificacionesNoLeidas(String usuarioId) async {
    try {
      final result = await Supabase.instance.client
          .from('notificaciones_sistema')
          .select('*')
          .eq('usuario_id', usuarioId)
          .eq('leida', false)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      print('Error obteniendo notificaciones no leídas: $e');
      return [];
    }
  }

  // Refrescar todos los datos
  Future<void> refrescarDatos() async {
    await Future.wait([
      cargarEstadisticas(),
      cargarDuenosPuntos(),
      cargarNotificaciones(),
    ]);
  }
} 