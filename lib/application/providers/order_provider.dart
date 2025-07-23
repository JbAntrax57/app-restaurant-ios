import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants.dart';
import '../../core/logger.dart';
import '../../core/exceptions.dart';

class OrderProvider extends ChangeNotifier {
  List<dynamic> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadOrders() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      AppLogger.logDatabaseOperation('select', 'orders');

      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('orders')
          .select('*, users(*)')
          .order('created_at', ascending: false);

      _orders = response;
      AppLogger.logDatabaseOperation('select', 'orders', data: '${_orders.length} orders loaded');
    } catch (e) {
      _error = 'Error al cargar los pedidos: $e';
      AppLogger.logDatabaseError('select', 'orders', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createOrder({
    required String userId,
    required List<Map<String, dynamic>> items,
    required double total,
    String? address,
    String? phone,
    String? notes,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      AppLogger.logDatabaseOperation('insert', 'orders');

      final supabase = Supabase.instance.client;
      final response = await supabase.from('orders').insert({
        'user_id': userId,
        'status': AppConstants.orderStatusPending,
        'total': total,
        'items': items,
        'address': address,
        'phone': phone,
        'notes': notes,
      }).select('*, users(*)').single();

      _orders.insert(0, response);
      AppLogger.logDatabaseOperation('insert', 'orders', data: 'Order created: ${response['id']}');
      return true;
    } catch (e) {
      _error = 'Error al crear el pedido: $e';
      AppLogger.logDatabaseError('insert', 'orders', e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      AppLogger.logDatabaseOperation('update', 'orders');

      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('orders')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId)
          .select('*, users(*)')
          .single();

      final index = _orders.indexWhere((order) => order['id'] == orderId);
      if (index != -1) {
        _orders[index] = response;
      }

      AppLogger.logDatabaseOperation('update', 'orders', data: 'Order status updated: $orderId to $status');
      return true;
    } catch (e) {
      _error = 'Error al actualizar el estado del pedido: $e';
      AppLogger.logDatabaseError('update', 'orders', e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteOrder(String orderId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      AppLogger.logDatabaseOperation('delete', 'orders');

      final supabase = Supabase.instance.client;
      await supabase.from('orders').delete().eq('id', orderId);

      _orders.removeWhere((order) => order['id'] == orderId);
      AppLogger.logDatabaseOperation('delete', 'orders', data: 'Order deleted: $orderId');
      return true;
    } catch (e) {
      _error = 'Error al eliminar el pedido: $e';
      AppLogger.logDatabaseError('delete', 'orders', e);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<dynamic> getOrdersByStatus(String status) {
    return _orders.where((order) => order['status'] == status).toList();
  }

  List<dynamic> getOrdersByUser(String userId) {
    return _orders.where((order) => order['user_id'] == userId).toList();
  }

  List<dynamic> getPendingOrders() {
    return getOrdersByStatus(AppConstants.orderStatusPending);
  }

  List<dynamic> getPreparingOrders() {
    return getOrdersByStatus(AppConstants.orderStatusPreparing);
  }

  List<dynamic> getReadyOrders() {
    return getOrdersByStatus(AppConstants.orderStatusReady);
  }

  List<dynamic> getDeliveringOrders() {
    return getOrdersByStatus(AppConstants.orderStatusDelivering);
  }

  List<dynamic> getDeliveredOrders() {
    return getOrdersByStatus(AppConstants.orderStatusDelivered);
  }

  List<dynamic> getCancelledOrders() {
    return getOrdersByStatus(AppConstants.orderStatusCancelled);
  }

  double getTotalRevenue() {
    return _orders.fold(0.0, (sum, order) {
      if (order['status'] == AppConstants.orderStatusDelivered) {
        return sum + (order['total'] ?? 0.0);
      }
      return sum;
    });
  }

  double getTodayRevenue() {
    final today = DateTime.now();
    return _orders.fold(0.0, (sum, order) {
      final orderDate = DateTime.parse(order['created_at']);
      if (orderDate.year == today.year &&
          orderDate.month == today.month &&
          orderDate.day == today.day &&
          order['status'] == AppConstants.orderStatusDelivered) {
        return sum + (order['total'] ?? 0.0);
      }
      return sum;
    });
  }

  int getOrdersCountByStatus(String status) {
    return getOrdersByStatus(status).length;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Datos demo para testing
  static const List<Map<String, dynamic>> demoOrders = [
    {
      'id': '1',
      'user_id': 'user1',
      'status': 'Pendiente',
      'total': 25.97,
      'items': [
        {
          'dish_id': '1',
          'name': 'Hamburguesa Clásica',
          'quantity': 2,
          'price': 12.99,
        },
      ],
      'address': 'Calle Principal 123',
      'phone': '555-0123',
      'notes': 'Sin cebolla',
      'created_at': '2024-01-15T10:30:00Z',
      'updated_at': '2024-01-15T10:30:00Z',
      'users': {
        'id': 'user1',
        'name': 'Juan Cliente',
        'email': 'cliente@demo.com',
        'role': 'cliente',
      },
    },
    {
      'id': '2',
      'user_id': 'user2',
      'status': 'En preparación',
      'total': 15.99,
      'items': [
        {
          'dish_id': '2',
          'name': 'Pizza Margherita',
          'quantity': 1,
          'price': 15.99,
        },
      ],
      'address': 'Avenida Central 456',
      'phone': '555-0456',
      'notes': null,
      'created_at': '2024-01-15T11:00:00Z',
      'updated_at': '2024-01-15T11:15:00Z',
      'users': {
        'id': 'user2',
        'name': 'María Cliente',
        'email': 'maria@demo.com',
        'role': 'cliente',
      },
    },
    {
      'id': '3',
      'user_id': 'user3',
      'status': 'Listo',
      'total': 8.99,
      'items': [
        {
          'dish_id': '3',
          'name': 'Ensalada César',
          'quantity': 1,
          'price': 8.99,
        },
      ],
      'address': 'Plaza Mayor 789',
      'phone': '555-0789',
      'notes': 'Aderezo extra',
      'created_at': '2024-01-15T11:30:00Z',
      'updated_at': '2024-01-15T11:45:00Z',
      'users': {
        'id': 'user3',
        'name': 'Carlos Cliente',
        'email': 'carlos@demo.com',
        'role': 'cliente',
      },
    },
  ];

  // Método para cargar pedidos demo (solo para desarrollo)
  Future<void> loadDemoOrders() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // Simular carga
    
    _orders = List.from(demoOrders);
    _isLoading = false;
    notifyListeners();
  }
} 