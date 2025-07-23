import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dish.dart';

class FirebaseService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'dishes';

  List<Dish> _dishes = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Dish> get dishes => _dishes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Obtener todos los platos
  Future<void> getDishes() async {
    _setLoading(true);
    _clearError();
    
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      _dishes = snapshot.docs.map((doc) {
        return Dish.fromMap(doc.data() as Map<String, dynamic>, doc.id);
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
      final docRef = await _firestore.collection(_collection).add(dish.toMap());
      final newDish = dish.copyWith(id: docRef.id);
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
      final updatedDish = dish.copyWith(updatedAt: DateTime.now());
      await _firestore
          .collection(_collection)
          .doc(dish.id)
          .update(updatedDish.toMap());

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
      await _firestore.collection(_collection).doc(id).delete();
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
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return Dish.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      _setError('Error al obtener platos por categoría: $e');
      return [];
    }
  }

  // Buscar platos por nombre
  Future<List<Dish>> searchDishes(String query) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + '\uf8ff')
          .get();

      return snapshot.docs.map((doc) {
        return Dish.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      _setError('Error al buscar platos: $e');
      return [];
    }
  }

  // Cambiar disponibilidad de un plato
  Future<bool> toggleDishAvailability(String id, bool isAvailable) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .update({
        'isAvailable': isAvailable,
        'updatedAt': DateTime.now(),
      });

      final index = _dishes.indexWhere((dish) => dish.id == id);
      if (index != -1) {
        _dishes[index] = _dishes[index].copyWith(
          isAvailable: isAvailable,
          updatedAt: DateTime.now(),
        );
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