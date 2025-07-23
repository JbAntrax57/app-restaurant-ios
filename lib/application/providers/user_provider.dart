import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/logger.dart';
import '../../core/exceptions.dart';

class UserProvider extends ChangeNotifier {
  List<dynamic> _users = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUsers() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      AppLogger.logDatabaseOperation('select', 'users');

      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('users')
          .select()
          .order('created_at', ascending: false);

      _users = response;
      AppLogger.logDatabaseOperation('select', 'users', data: '${_users.length} users loaded');
    } catch (e) {
      _error = 'Error al cargar los usuarios: $e';
      AppLogger.logDatabaseError('select', 'users', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createUser({
    required String email,
    required String name,
    required String role,
    String? phone,
    String? address,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      AppLogger.logDatabaseOperation('insert', 'users');

      final supabase = Supabase.instance.client;
      final response = await supabase.from('users').insert({
        'email': email,
        'name': name,
        'role': role,
        'phone': phone,
        'address': address,
      }).select().single();

      _users.insert(0, response);
      AppLogger.logDatabaseOperation('insert', 'users', data: 'User created: ${response['id']}');
      return true;
    } catch (e) {
      _error = 'Error al crear el usuario: $e';
      AppLogger.logDatabaseError('insert', 'users', e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUser({
    required String id,
    String? name,
    String? role,
    String? phone,
    String? address,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      AppLogger.logDatabaseOperation('update', 'users');

      final supabase = Supabase.instance.client;
      final updateData = <String, dynamic>{};
      
      if (name != null) updateData['name'] = name;
      if (role != null) updateData['role'] = role;
      if (phone != null) updateData['phone'] = phone;
      if (address != null) updateData['address'] = address;
      
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await supabase
          .from('users')
          .update(updateData)
          .eq('id', id)
          .select()
          .single();

      final index = _users.indexWhere((user) => user['id'] == id);
      if (index != -1) {
        _users[index] = response;
      }

      AppLogger.logDatabaseOperation('update', 'users', data: 'User updated: $id');
      return true;
    } catch (e) {
      _error = 'Error al actualizar el usuario: $e';
      AppLogger.logDatabaseError('update', 'users', e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteUser(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      AppLogger.logDatabaseOperation('delete', 'users');

      final supabase = Supabase.instance.client;
      await supabase.from('users').delete().eq('id', id);

      _users.removeWhere((user) => user['id'] == id);
      AppLogger.logDatabaseOperation('delete', 'users', data: 'User deleted: $id');
      return true;
    } catch (e) {
      _error = 'Error al eliminar el usuario: $e';
      AppLogger.logDatabaseError('delete', 'users', e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<dynamic> getUsersByRole(String role) {
    return _users.where((user) => user['role'] == role).toList();
  }

  List<dynamic> getClients() {
    return getUsersByRole('cliente');
  }

  List<dynamic> getOwners() {
    return getUsersByRole('duenio');
  }

  List<dynamic> getDeliveryUsers() {
    return getUsersByRole('repartidor');
  }

  List<dynamic> getAdmins() {
    return getUsersByRole('admin');
  }

  int getUsersCountByRole(String role) {
    return getUsersByRole(role).length;
  }

  dynamic getUserById(String id) {
    try {
      return _users.firstWhere((user) => user['id'] == id);
    } catch (e) {
      return null;
    }
  }

  List<dynamic> searchUsers(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _users.where((user) {
      final name = user['name']?.toString().toLowerCase() ?? '';
      final email = user['email']?.toString().toLowerCase() ?? '';
      return name.contains(lowercaseQuery) || email.contains(lowercaseQuery);
    }).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Datos demo para testing
  static const List<Map<String, dynamic>> demoUsers = [
    {
      'id': 'user1',
      'email': 'cliente@demo.com',
      'name': 'Juan Cliente',
      'role': 'cliente',
      'phone': '555-0123',
      'address': 'Calle Principal 123',
      'created_at': '2024-01-01T00:00:00Z',
      'updated_at': '2024-01-01T00:00:00Z',
    },
    {
      'id': 'user2',
      'email': 'duenio@demo.com',
      'name': 'María Dueña',
      'role': 'duenio',
      'phone': '555-0456',
      'address': 'Avenida Central 456',
      'created_at': '2024-01-01T00:00:00Z',
      'updated_at': '2024-01-01T00:00:00Z',
    },
    {
      'id': 'user3',
      'email': 'repartidor@demo.com',
      'name': 'Carlos Repartidor',
      'role': 'repartidor',
      'phone': '555-0789',
      'address': 'Plaza Mayor 789',
      'created_at': '2024-01-01T00:00:00Z',
      'updated_at': '2024-01-01T00:00:00Z',
    },
    {
      'id': 'user4',
      'email': 'admin@demo.com',
      'name': 'Admin Sistema',
      'role': 'admin',
      'phone': '555-0000',
      'address': 'Oficina Central',
      'created_at': '2024-01-01T00:00:00Z',
      'updated_at': '2024-01-01T00:00:00Z',
    },
    {
      'id': 'user5',
      'email': 'maria@demo.com',
      'name': 'María Cliente',
      'role': 'cliente',
      'phone': '555-1111',
      'address': 'Calle Secundaria 321',
      'created_at': '2024-01-02T00:00:00Z',
      'updated_at': '2024-01-02T00:00:00Z',
    },
    {
      'id': 'user6',
      'email': 'carlos@demo.com',
      'name': 'Carlos Cliente',
      'role': 'cliente',
      'phone': '555-2222',
      'address': 'Boulevard Norte 654',
      'created_at': '2024-01-03T00:00:00Z',
      'updated_at': '2024-01-03T00:00:00Z',
    },
  ];

  // Método para cargar usuarios demo (solo para desarrollo)
  Future<void> loadDemoUsers() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // Simular carga
    
    _users = List.from(demoUsers);
    _isLoading = false;
    notifyListeners();
  }
} 