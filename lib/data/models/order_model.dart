import '../../core/constants.dart';

class OrderItem {
  final String dishId;
  final String dishName;
  final int quantity;
  final double price;
  final Map<String, dynamic>? extras;

  OrderItem({
    required this.dishId,
    required this.dishName,
    required this.quantity,
    required this.price,
    this.extras,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      dishId: json['dish_id'] ?? '',
      dishName: json['dish_name'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0.0).toDouble(),
      extras: json['extras'] != null ? Map<String, dynamic>.from(json['extras']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dish_id': dishId,
      'dish_name': dishName,
      'quantity': quantity,
      'price': price,
      'extras': extras,
    };
  }

  double get total => price * quantity;
}

class OrderModel {
  final String id;
  final String userId;
  final String? businessId;
  final String status;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double total;
  final List<OrderItem> items;
  final String? address;
  final String? phone;
  final String? notes;
  final String? deliveryInstructions;
  final DateTime? estimatedDeliveryTime;
  final DateTime? actualDeliveryTime;
  final String? deliveryUserId; // ID del repartidor
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    this.businessId,
    required this.status,
    required this.subtotal,
    required this.tax,
    required this.deliveryFee,
    required this.total,
    required this.items,
    this.address,
    this.phone,
    this.notes,
    this.deliveryInstructions,
    this.estimatedDeliveryTime,
    this.actualDeliveryTime,
    this.deliveryUserId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    final items = itemsList.map((item) => OrderItem.fromJson(item)).toList();

    return OrderModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      businessId: json['business_id'],
      status: json['status'] ?? AppConstants.orderStatusPending,
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      tax: (json['tax'] ?? 0.0).toDouble(),
      deliveryFee: (json['delivery_fee'] ?? 0.0).toDouble(),
      total: (json['total'] ?? 0.0).toDouble(),
      items: items,
      address: json['address'],
      phone: json['phone'],
      notes: json['notes'],
      deliveryInstructions: json['delivery_instructions'],
      estimatedDeliveryTime: json['estimated_delivery_time'] != null 
          ? DateTime.parse(json['estimated_delivery_time'])
          : null,
      actualDeliveryTime: json['actual_delivery_time'] != null 
          ? DateTime.parse(json['actual_delivery_time'])
          : null,
      deliveryUserId: json['delivery_user_id'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'business_id': businessId,
      'status': status,
      'subtotal': subtotal,
      'tax': tax,
      'delivery_fee': deliveryFee,
      'total': total,
      'items': items.map((item) => item.toJson()).toList(),
      'address': address,
      'phone': phone,
      'notes': notes,
      'delivery_instructions': deliveryInstructions,
      'estimated_delivery_time': estimatedDeliveryTime?.toIso8601String(),
      'actual_delivery_time': actualDeliveryTime?.toIso8601String(),
      'delivery_user_id': deliveryUserId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    String? businessId,
    String? status,
    double? subtotal,
    double? tax,
    double? deliveryFee,
    double? total,
    List<OrderItem>? items,
    String? address,
    String? phone,
    String? notes,
    String? deliveryInstructions,
    DateTime? estimatedDeliveryTime,
    DateTime? actualDeliveryTime,
    String? deliveryUserId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      businessId: businessId ?? this.businessId,
      status: status ?? this.status,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      items: items ?? this.items,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      actualDeliveryTime: actualDeliveryTime ?? this.actualDeliveryTime,
      deliveryUserId: deliveryUserId ?? this.deliveryUserId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isPending => status == AppConstants.orderStatusPending;
  bool get isPreparing => status == AppConstants.orderStatusPreparing;
  bool get isReady => status == AppConstants.orderStatusReady;
  bool get isDelivering => status == AppConstants.orderStatusDelivering;
  bool get isDelivered => status == AppConstants.orderStatusDelivered;
  bool get isCancelled => status == AppConstants.orderStatusCancelled;

  String get statusText {
    switch (status) {
      case AppConstants.orderStatusPending:
        return 'Pendiente';
      case AppConstants.orderStatusPreparing:
        return 'En preparación';
      case AppConstants.orderStatusReady:
        return 'Listo';
      case AppConstants.orderStatusDelivering:
        return 'En entrega';
      case AppConstants.orderStatusDelivered:
        return 'Entregado';
      case AppConstants.orderStatusCancelled:
        return 'Cancelado';
      default:
        return 'Desconocido';
    }
  }

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  @override
  String toString() {
    return 'OrderModel(id: $id, status: $status, total: $total, items: ${items.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 