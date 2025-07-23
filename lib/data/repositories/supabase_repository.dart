import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/env.dart';
import '../../core/logger.dart';
import '../models/user_model.dart';
import '../models/dish_model.dart';
import '../models/order_model.dart';
import '../models/business_model.dart';

class SupabaseRepository {
  static final SupabaseClient _client = Supabase.instance.client;

  // =====================================================
  // USUARIOS
  // =====================================================

  static Future<List<UserModel>> getUsers() async {
    try {
      final response = await _client
          .from('users')
          .select()
          .order('created_at', ascending: false);
      
      return response.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error getting users: $e');
      rethrow;
    }
  }

  static Future<UserModel?> getUserById(String id) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('id', id)
          .single();
      
      return UserModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Error getting user by id: $e');
      return null;
    }
  }

  static Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      final response = await _client
          .from('users')
          .select()
          .eq('role', role)
          .eq('is_active', true)
          .order('created_at', ascending: false);
      
      return response.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error getting users by role: $e');
      rethrow;
    }
  }

  static Future<UserModel?> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await _client
          .from('users')
          .insert(userData)
          .select()
          .single();
      
      return UserModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Error creating user: $e');
      return null;
    }
  }

  static Future<bool> updateUser(String id, Map<String, dynamic> userData) async {
    try {
      await _client
          .from('users')
          .update(userData)
          .eq('id', id);
      
      return true;
    } catch (e) {
      AppLogger.error('Error updating user: $e');
      return false;
    }
  }

  static Future<bool> deleteUser(String id) async {
    try {
      await _client
          .from('users')
          .delete()
          .eq('id', id);
      
      return true;
    } catch (e) {
      AppLogger.error('Error deleting user: $e');
      return false;
    }
  }

  // =====================================================
  // PLATOS
  // =====================================================

  static Future<List<DishModel>> getDishes() async {
    try {
      final response = await _client
          .from('dishes')
          .select()
          .eq('is_available', true)
          .order('created_at', ascending: false);
      
      return response.map((json) => DishModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error getting dishes: $e');
      rethrow;
    }
  }

  static Future<List<DishModel>> getDishesByCategory(String category) async {
    try {
      final response = await _client
          .from('dishes')
          .select()
          .eq('category', category)
          .eq('is_available', true)
          .order('name');
      
      return response.map((json) => DishModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error getting dishes by category: $e');
      rethrow;
    }
  }

  static Future<List<DishModel>> searchDishes(String query) async {
    try {
      final response = await _client
          .from('dishes')
          .select()
          .ilike('name', '%$query%')
          .eq('is_available', true)
          .order('name');
      
      return response.map((json) => DishModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error searching dishes: $e');
      rethrow;
    }
  }

  static Future<DishModel?> getDishById(String id) async {
    try {
      final response = await _client
          .from('dishes')
          .select()
          .eq('id', id)
          .single();
      
      return DishModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Error getting dish by id: $e');
      return null;
    }
  }

  static Future<DishModel?> createDish(Map<String, dynamic> dishData) async {
    try {
      final response = await _client
          .from('dishes')
          .insert(dishData)
          .select()
          .single();
      
      return DishModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Error creating dish: $e');
      return null;
    }
  }

  static Future<bool> updateDish(String id, Map<String, dynamic> dishData) async {
    try {
      await _client
          .from('dishes')
          .update(dishData)
          .eq('id', id);
      
      return true;
    } catch (e) {
      AppLogger.error('Error updating dish: $e');
      return false;
    }
  }

  static Future<bool> deleteDish(String id) async {
    try {
      await _client
          .from('dishes')
          .delete()
          .eq('id', id);
      
      return true;
    } catch (e) {
      AppLogger.error('Error deleting dish: $e');
      return false;
    }
  }

  // =====================================================
  // PEDIDOS
  // =====================================================

  static Future<List<OrderModel>> getOrders() async {
    try {
      final response = await _client
          .from('orders')
          .select()
          .order('created_at', ascending: false);
      
      return response.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error getting orders: $e');
      rethrow;
    }
  }

  static Future<List<OrderModel>> getOrdersByUser(String userId) async {
    try {
      final response = await _client
          .from('orders')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return response.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error getting orders by user: $e');
      rethrow;
    }
  }

  static Future<List<OrderModel>> getOrdersByStatus(String status) async {
    try {
      final response = await _client
          .from('orders')
          .select()
          .eq('status', status)
          .order('created_at', ascending: false);
      
      return response.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error getting orders by status: $e');
      rethrow;
    }
  }

  static Future<OrderModel?> getOrderById(String id) async {
    try {
      final response = await _client
          .from('orders')
          .select()
          .eq('id', id)
          .single();
      
      return OrderModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Error getting order by id: $e');
      return null;
    }
  }

  static Future<OrderModel?> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await _client
          .from('orders')
          .insert(orderData)
          .select()
          .single();
      
      return OrderModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Error creating order: $e');
      return null;
    }
  }

  static Future<bool> updateOrder(String id, Map<String, dynamic> orderData) async {
    try {
      await _client
          .from('orders')
          .update(orderData)
          .eq('id', id);
      
      return true;
    } catch (e) {
      AppLogger.error('Error updating order: $e');
      return false;
    }
  }

  static Future<bool> deleteOrder(String id) async {
    try {
      await _client
          .from('orders')
          .delete()
          .eq('id', id);
      
      return true;
    } catch (e) {
      AppLogger.error('Error deleting order: $e');
      return false;
    }
  }

  // =====================================================
  // NEGOCIOS
  // =====================================================

  static Future<List<BusinessModel>> getBusinesses() async {
    try {
      final response = await _client
          .from('businesses')
          .select()
          .eq('is_active', true)
          .order('name');
      
      return response.map((json) => BusinessModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error getting businesses: $e');
      rethrow;
    }
  }

  static Future<BusinessModel?> getBusinessById(String id) async {
    try {
      final response = await _client
          .from('businesses')
          .select()
          .eq('id', id)
          .single();
      
      return BusinessModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Error getting business by id: $e');
      return null;
    }
  }

  static Future<BusinessModel?> getBusinessByOwner(String ownerId) async {
    try {
      final response = await _client
          .from('businesses')
          .select()
          .eq('owner_id', ownerId)
          .single();
      
      return BusinessModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Error getting business by owner: $e');
      return null;
    }
  }

  static Future<BusinessModel?> createBusiness(Map<String, dynamic> businessData) async {
    try {
      final response = await _client
          .from('businesses')
          .insert(businessData)
          .select()
          .single();
      
      return BusinessModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Error creating business: $e');
      return null;
    }
  }

  static Future<bool> updateBusiness(String id, Map<String, dynamic> businessData) async {
    try {
      await _client
          .from('businesses')
          .update(businessData)
          .eq('id', id);
      
      return true;
    } catch (e) {
      AppLogger.error('Error updating business: $e');
      return false;
    }
  }

  // =====================================================
  // AUTENTICACIÓN
  // =====================================================

  static Future<AuthResponse?> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Error signing in: $e');
      return null;
    }
  }

  static Future<AuthResponse?> signUp(String email, String password, Map<String, dynamic> userData) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: userData,
      );
      
      return response;
    } catch (e) {
      AppLogger.error('Error signing up: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      AppLogger.error('Error signing out: $e');
    }
  }

  static User? getCurrentUser() {
    try {
      return _client.auth.currentUser;
    } catch (e) {
      AppLogger.error('Error getting current user: $e');
      return null;
    }
  }

  // =====================================================
  // UTILIDADES
  // =====================================================

  static bool isConnected() {
    try {
      return _client.auth.currentUser != null;
    } catch (e) {
      return false;
    }
  }

  static String? getUserId() {
    try {
      return _client.auth.currentUser?.id;
    } catch (e) {
      return null;
    }
  }

  static String? getUserEmail() {
    try {
      return _client.auth.currentUser?.email;
    } catch (e) {
      return null;
    }
  }
} 