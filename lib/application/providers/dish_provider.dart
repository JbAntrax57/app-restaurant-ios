import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/logger.dart';
import '../../core/exceptions.dart';

class DishProvider extends ChangeNotifier {
  List<dynamic> _dishes = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get dishes => _dishes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDishes() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      AppLogger.logDatabaseOperation('select', 'platos');

      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('platos')
          .select()
          .order('created_at', ascending: false);

      _dishes = response;
      AppLogger.logDatabaseOperation('select', 'platos', data: '${_dishes.length} dishes loaded');
    } catch (e) {
      _error = 'Error al cargar los platos: $e';
      AppLogger.logDatabaseError('select', 'platos', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createDish({
    required String name,
    required String description,
    required double price,
    required String category,
    String? imageUrl,
    bool isAvailable = true,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      AppLogger.logDatabaseOperation('insert', 'platos');

      final supabase = Supabase.instance.client;
      final response = await supabase.from('platos').insert({
        'nombre': name,
        'descripcion': description,
        'precio': price,
        'categoria': category,
        'imagen_url': imageUrl,
        'disponible': isAvailable,
      }).select().single();

      _dishes.insert(0, response);
      AppLogger.logDatabaseOperation('insert', 'platos', data: 'Dish created: ${response['id']}');
      return true;
    } catch (e) {
      _error = 'Error al crear el plato: $e';
      AppLogger.logDatabaseError('insert', 'platos', e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateDish({
    required String id,
    String? name,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    bool? isAvailable,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      AppLogger.logDatabaseOperation('update', 'platos');

      final supabase = Supabase.instance.client;
      final updateData = <String, dynamic>{};
      
      if (name != null) updateData['nombre'] = name;
      if (description != null) updateData['descripcion'] = description;
      if (price != null) updateData['precio'] = price;
      if (category != null) updateData['categoria'] = category;
      if (imageUrl != null) updateData['imagen_url'] = imageUrl;
      if (isAvailable != null) updateData['disponible'] = isAvailable;
      
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await supabase
          .from('platos')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      final index = _dishes.indexWhere((dish) => dish['id'] == id);
      if (index != -1) {
        _dishes[index] = response;
      }

      AppLogger.logDatabaseOperation('update', 'platos', data: 'Dish updated: $id');
      return true;
    } catch (e) {
      _error = 'Error al actualizar el plato: $e';
      AppLogger.logDatabaseError('update', 'platos', e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteDish(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      AppLogger.logDatabaseOperation('delete', 'platos');

      final supabase = Supabase.instance.client;
      await supabase.from('platos').delete().eq('id', id);

      _dishes.removeWhere((dish) => dish['id'] == id);
      AppLogger.logDatabaseOperation('delete', 'platos', data: 'Dish deleted: $id');
      return true;
    } catch (e) {
      _error = 'Error al eliminar el plato: $e';
      AppLogger.logDatabaseError('delete', 'platos', e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleAvailability(String id) async {
    try {
      final dish = _dishes.firstWhere((dish) => dish['id'] == id);
      final currentAvailability = dish['disponible'] ?? true;
      
      return await updateDish(
        id: id,
        isAvailable: !currentAvailability,
      );
    } catch (e) {
      _error = 'Error al cambiar disponibilidad: $e';
      return false;
    }
  }

  List<dynamic> getDishesByCategory(String category) {
    return _dishes.where((dish) => dish['categoria'] == category).toList();
  }

  List<dynamic> getAvailableDishes() {
    return _dishes.where((dish) => dish['disponible'] == true).toList();
  }

  List<dynamic> searchDishes(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _dishes.where((dish) {
      final name = dish['nombre']?.toString().toLowerCase() ?? '';
      final description = dish['descripcion']?.toString().toLowerCase() ?? '';
      return name.contains(lowercaseQuery) || description.contains(lowercaseQuery);
    }).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Datos demo para testing
  static const List<Map<String, dynamic>> demoDishes = [
    {
      'id': '1',
      'name': 'Hamburguesa Clásica',
      'description': 'Hamburguesa con carne, lechuga, tomate y queso',
      'price': 12.99,
      'category': 'Platos principales',
      'image_url': null,
      'is_available': true,
      'created_at': '2024-01-01T00:00:00Z',
    },
    {
      'id': '2',
      'name': 'Pizza Margherita',
      'description': 'Pizza con salsa de tomate, mozzarella y albahaca',
      'price': 15.99,
      'category': 'Platos principales',
      'image_url': null,
      'is_available': true,
      'created_at': '2024-01-01T00:00:00Z',
    },
    {
      'id': '3',
      'name': 'Ensalada César',
      'description': 'Lechuga, crutones, parmesano y aderezo César',
      'price': 8.99,
      'category': 'Entradas',
      'image_url': null,
      'is_available': true,
      'created_at': '2024-01-01T00:00:00Z',
    },
    {
      'id': '4',
      'name': 'Tiramisú',
      'description': 'Postre italiano con café y mascarpone',
      'price': 6.99,
      'category': 'Postres',
      'image_url': null,
      'is_available': true,
      'created_at': '2024-01-01T00:00:00Z',
    },
    {
      'id': '5',
      'name': 'Coca Cola',
      'description': 'Refresco de cola 350ml',
      'price': 2.50,
      'category': 'Bebidas',
      'image_url': null,
      'is_available': true,
      'created_at': '2024-01-01T00:00:00Z',
    },
  ];

  // Método para cargar datos demo (solo para desarrollo)
  Future<void> loadDemoDishes() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // Simular carga
    
    _dishes = List.from(demoDishes);
    _isLoading = false;
    notifyListeners();
  }
} 