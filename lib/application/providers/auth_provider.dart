import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/logger.dart';
import '../../core/exceptions.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Getter para el nombre del usuario
  String get userName {
    if (_userProfile != null && _userProfile!['email'] != null) {
      return _userProfile!['email'].split('@')[0];
    }
    if (_currentUser?.email != null) {
      return _currentUser!.email!.split('@')[0];
    }
    return 'Usuario';
  }

  // Getter para el rol del usuario
  String get userRole {
    return _userProfile?['rol'] ?? 'cliente';
  }

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    final supabase = Supabase.instance.client;
    _currentUser = supabase.auth.currentUser;
    
    if (_currentUser != null) {
      _loadUserProfile();
    }
    
    // Escuchar cambios en la autenticación
    supabase.auth.onAuthStateChange.listen((data) {
      _currentUser = data.session?.user;
      if (_currentUser != null) {
        _loadUserProfile();
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserProfile() async {
    if (_currentUser == null) return;
    
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('usuarios')
          .select()
          .eq('id', _currentUser!.id)
          .single();
      
      _userProfile = response;
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error loading user profile: $e', tag: 'Auth');
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      AppLogger.info('Login attempt for user: $email with role: $role', tag: 'Auth');

      final supabase = Supabase.instance.client;
      
      // Verificar si el usuario existe en la tabla usuarios
      final userData = await supabase
          .from('usuarios')
          .select()
          .eq('email', email)
          .eq('password', password)
          .eq('rol', role)
          .single();

      if (userData == null) {
        _error = 'Usuario no encontrado o credenciales incorrectas';
        AppLogger.error('User not found or invalid credentials: $email, role: $role', tag: 'Auth');
        return false;
      }

      // Simular login exitoso (ya que verificamos en la tabla usuarios)
      _currentUser = User(
        id: userData['id'],
        email: userData['email'],
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        aud: 'authenticated',
        role: 'authenticated',
        appMetadata: {},
        userMetadata: {},
        identities: [],
        factors: [],
      );
      _userProfile = userData;
      
      AppLogger.info('Login successful for user: ${userData['id']}', tag: 'Auth');
      return true;
    } catch (e) {
      _error = 'Error al iniciar sesión: $e';
      AppLogger.error('Login exception: $e', tag: 'Auth');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String role,
    String? phone,
    String? address,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      AppLogger.info('Register attempt for user: $email', tag: 'Auth');

      final supabase = Supabase.instance.client;
      
      // Crear el usuario directamente en la tabla usuarios
      final userData = await supabase.from('usuarios').insert({
        'email': email,
        'password': password,
        'rol': role,
        'restauranteid': null,
      }).select().single();

      if (userData != null) {
        _currentUser = User(
          id: userData['id'],
          email: userData['email'],
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          aud: 'authenticated',
          role: 'authenticated',
          appMetadata: {},
          userMetadata: {},
          identities: [],
          factors: [],
        );
        _userProfile = userData;
        AppLogger.info('Register successful for user: ${userData['id']}', tag: 'Auth');
        return true;
      } else {
        _error = 'Error al crear la cuenta';
        AppLogger.error('Failed to create account for user: $email', tag: 'Auth');
        return false;
      }
    } catch (e) {
      _error = 'Error al registrar: $e';
      AppLogger.error('Register exception: $e', tag: 'Auth');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      AppLogger.info('Logout attempt for user: ${_currentUser?.id}', tag: 'Auth');

      final supabase = Supabase.instance.client;
      await supabase.auth.signOut();
      
      _currentUser = null;
      _userProfile = null;
      AppLogger.info('Logout successful', tag: 'Auth');
    } catch (e) {
      AppLogger.error('Logout exception: $e', tag: 'Auth');
    } finally {
      notifyListeners();
    }
  }

  Future<bool> isAuthenticated() async {
    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;
    return session != null;
  }

  Future<void> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      AppLogger.info('Reset password attempt for user: $email', tag: 'Auth');

      final supabase = Supabase.instance.client;
      await supabase.auth.resetPasswordForEmail(email);

      AppLogger.info('Reset password successful for user: $email', tag: 'Auth');
    } catch (e) {
      _error = 'Error al enviar el email de recuperación: $e';
      AppLogger.error('Reset password exception: $e', tag: 'Auth');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required String name,
    String? phone,
    String? address,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_currentUser == null) {
        throw AuthenticationException('Usuario no autenticado');
      }

      AppLogger.info('Update profile attempt for user: ${_currentUser!.id}', tag: 'Auth');

      final supabase = Supabase.instance.client;
      await supabase.from('usuarios').update({
        'nombre': name,
        'telefono': phone,
        'direccion': address,
        'fechaActualizacion': DateTime.now().toIso8601String(),
      }).eq('id', _currentUser!.id);

      _userProfile = {
        ..._userProfile!,
        'nombre': name,
        'telefono': phone,
        'direccion': address,
      };

      AppLogger.info('Update profile successful for user: ${_currentUser!.id}', tag: 'Auth');
    } catch (e) {
      _error = 'Error al actualizar perfil: $e';
      AppLogger.error('Update profile exception: $e', tag: 'Auth');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Usuarios demo para testing
  static const Map<String, Map<String, String>> demoUsers = {
    'cliente': {
      'email': 'cliente1@demo.com',
      'password': '1234',
      'name': 'Juan Cliente',
      'role': 'cliente',
    },
    'duenio': {
      'email': 'duenio@demo.com',
      'password': '123456',
      'name': 'María Dueña',
      'role': 'duenio',
    },
    'repartidor': {
      'email': 'repartidor@demo.com',
      'password': '123456',
      'name': 'Carlos Repartidor',
      'role': 'repartidor',
    },
    'admin': {
      'email': 'admin@demo.com',
      'password': '123456',
      'name': 'Admin Sistema',
      'role': 'admin',
    },
  };

  // Método para login con usuarios demo (solo para desarrollo)
  Future<bool> loginWithDemoUser(String role) async {
    final demoUser = demoUsers[role];
    if (demoUser != null) {
      return await login(
        email: demoUser['email']!,
        password: demoUser['password']!,
        role: demoUser['role']!,
      );
    }
    return false;
  }
} 