import 'package:flutter/material.dart';
import '../../core/logger.dart';

class CartItem {
  final dynamic dish;
  int quantity;

  CartItem({
    required this.dish,
    required this.quantity,
  });

  double get total => dish['price'] * quantity;
}

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _error;

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.length;
  double get total => _items.fold(0, (sum, item) => sum + item.total);

  void addToCart(dynamic dish) {
    try {
      AppLogger.logCacheOperation('add', 'cart_item_${dish['id']}');

      final existingIndex = _items.indexWhere((item) => item.dish['id'] == dish['id']);
      
      if (existingIndex >= 0) {
        // Si ya existe, incrementar cantidad
        _items[existingIndex].quantity++;
        AppLogger.logCacheOperation('update', 'cart_item_${dish['id']}');
      } else {
        // Si no existe, agregar nuevo item
        _items.add(CartItem(dish: dish, quantity: 1));
        AppLogger.logCacheOperation('add', 'cart_item_${dish['id']}');
      }

      notifyListeners();
    } catch (e) {
      _error = 'Error al agregar al carrito: $e';
      AppLogger.logCacheError('add', 'cart_item_${dish['id']}', e);
      notifyListeners();
    }
  }

  void removeFromCart(String dishId) {
    try {
      AppLogger.logCacheOperation('remove', 'cart_item_$dishId');

      _items.removeWhere((item) => item.dish['id'] == dishId);
      notifyListeners();
    } catch (e) {
      _error = 'Error al remover del carrito: $e';
      AppLogger.logCacheError('remove', 'cart_item_$dishId', e);
      notifyListeners();
    }
  }

  void updateQuantity(String dishId, int quantity) {
    try {
      AppLogger.logCacheOperation('update', 'cart_item_$dishId');

      final itemIndex = _items.indexWhere((item) => item.dish['id'] == dishId);
      
      if (itemIndex >= 0) {
        if (quantity <= 0) {
          _items.removeAt(itemIndex);
        } else {
          _items[itemIndex].quantity = quantity;
        }
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error al actualizar cantidad: $e';
      AppLogger.logCacheError('update', 'cart_item_$dishId', e);
      notifyListeners();
    }
  }

  void clearCart() {
    try {
      AppLogger.logCacheOperation('clear', 'cart');

      _items.clear();
      notifyListeners();
    } catch (e) {
      _error = 'Error al vaciar el carrito: $e';
      AppLogger.logCacheError('clear', 'cart', e);
      notifyListeners();
    }
  }

  int getQuantity(String dishId) {
    final item = _items.firstWhere(
      (item) => item.dish['id'] == dishId,
      orElse: () => CartItem(dish: {}, quantity: 0),
    );
    return item.quantity;
  }

  bool isInCart(String dishId) {
    return _items.any((item) => item.dish['id'] == dishId);
  }

  List<dynamic> getDishes() {
    return _items.map((item) => item.dish).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'items': _items.map((item) => {
        'dish_id': item.dish['id'],
        'quantity': item.quantity,
        'price': item.dish['price'],
        'name': item.dish['name'],
      }).toList(),
      'total': total,
      'item_count': itemCount,
    };
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Método para cargar carrito desde JSON (para persistencia)
  void loadFromJson(Map<String, dynamic> json) {
    try {
      _items.clear();
      
      final itemsList = json['items'] as List<dynamic>;
      for (final itemData in itemsList) {
        final dish = {
          'id': itemData['dish_id'],
          'name': itemData['name'],
          'price': itemData['price'],
        };
        
        _items.add(CartItem(
          dish: dish,
          quantity: itemData['quantity'],
        ));
      }
      
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar el carrito: $e';
      notifyListeners();
    }
  }

  // Datos demo para testing
  static const List<Map<String, dynamic>> demoCartItems = [
    {
      'dish': {
        'id': '1',
        'name': 'Hamburguesa Clásica',
        'description': 'Hamburguesa con carne, lechuga, tomate y queso',
        'price': 12.99,
        'category': 'Platos principales',
        'image_url': null,
        'is_available': true,
      },
      'quantity': 2,
    },
    {
      'dish': {
        'id': '3',
        'name': 'Ensalada César',
        'description': 'Lechuga, crutones, parmesano y aderezo César',
        'price': 8.99,
        'category': 'Entradas',
        'image_url': null,
        'is_available': true,
      },
      'quantity': 1,
    },
  ];

  // Método para cargar carrito demo (solo para desarrollo)
  void loadDemoCart() {
    _items.clear();
    
    for (final itemData in demoCartItems) {
      _items.add(CartItem(
        dish: itemData['dish'],
        quantity: itemData['quantity'],
      ));
    }
    
    notifyListeners();
  }
} 