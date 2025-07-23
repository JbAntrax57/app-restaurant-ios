import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/dish.dart';
import '../config/supabase_config.dart';

class SupabaseService extends ChangeNotifier {
  late final SupabaseClient _supabase;
  final String _table = 'dishes';

  SupabaseService() {
    _initializeSupabase();
  }

  List<Dish> _dishes = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Dish> get dishes => _dishes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Inicializar Supabase
  void _initializeSupabase() {
    _supabase = Supabase.instance.client;
  }

  // Obtener todos los platos
  Future<void> getDishes() async {
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _supabase
          .from(_table)
          .select()
          .order('created_at', ascending: false);

      _dishes = (response as List).map((data) {
        return Dish.fromMap(data, data['id']?.toString() ?? '');
      }).toList();

      _setLoading(false);
    } catch (e) {
      _setError('Error al cargar los platos: $e');
      _setLoading(false);
    }
  }

  // Crear un nuevo plato
  Future<bool> createDish(Dish dish) async {
    _setLoading(true);
    _clearError();
    
    try {
      final data = dish.toMap();
      data['created_at'] = DateTime.now().toIso8601String();
      data['updated_at'] = DateTime.now().toIso8601String();
      
      final response = await _supabase
          .from(_table)
          .insert(data)
          .select()
          .single();

      final newDish = Dish.fromMap(response, response['id']?.toString() ?? '');
      _dishes.insert(0, newDish);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error al crear el plato: $e');
      _setLoading(false);
      return false;
    }
  }

  // Actualizar un plato
  Future<bool> updateDish(Dish dish) async {
    if (dish.id == null) return false;
    
    _setLoading(true);
    _clearError();
    
    try {
      final data = dish.toMap();
      data['updated_at'] = DateTime.now().toIso8601String();
      
      final response = await _supabase
          .from(_table)
          .update(data)
          .eq('id', dish.id!)
          .select()
          .single();

      final updatedDish = Dish.fromMap(response, response['id']?.toString() ?? '');
      final index = _dishes.indexWhere((d) => d.id == dish.id);
      if (index != -1) {
        _dishes[index] = updatedDish;
      }
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error al actualizar el plato: $e');
      _setLoading(false);
      return false;
    }
  }

  // Eliminar un plato
  Future<bool> deleteDish(String id) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _supabase
          .from(_table)
          .delete()
          .eq('id', id);

      _dishes.removeWhere((dish) => dish.id == id);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Error al eliminar el plato: $e');
      _setLoading(false);
      return false;
    }
  }

  // Obtener platos por categoría
  Future<List<Dish>> getDishesByCategory(String category) async {
    try {
      final response = await _supabase
          .from(_table)
          .select()
          .eq('category', category)
          .order('created_at', ascending: false);

      return (response as List).map((data) {
        return Dish.fromMap(data, data['id']?.toString() ?? '');
      }).toList();
    } catch (e) {
      _setError('Error al obtener platos por categoría: $e');
      return [];
    }
  }

  // Buscar platos por nombre
  Future<List<Dish>> searchDishes(String query) async {
    try {
      final response = await _supabase
          .from(_table)
          .select()
          .ilike('name', '%$query%')
          .order('created_at', ascending: false);

      return (response as List).map((data) {
        return Dish.fromMap(data, data['id']?.toString() ?? '');
      }).toList();
    } catch (e) {
      _setError('Error al buscar platos: $e');
      return [];
    }
  }

  // Cambiar disponibilidad de un plato
  Future<bool> toggleDishAvailability(String id, bool isAvailable) async {
    try {
      final response = await _supabase
          .from(_table)
          .update({
            'is_available': isAvailable,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .select()
          .single();

      final updatedDish = Dish.fromMap(response, response['id']?.toString() ?? '');
      final index = _dishes.indexWhere((dish) => dish.id == id);
      if (index != -1) {
        _dishes[index] = updatedDish;
      }
      
      return true;
    } catch (e) {
      _setError('Error al cambiar disponibilidad: $e');
      return false;
    }
  }

  // Métodos privados para manejar el estado
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Limpiar datos
  void clearData() {
    _dishes.clear();
    _error = null;
    notifyListeners();
  }
} 