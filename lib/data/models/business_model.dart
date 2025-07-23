class BusinessModel {
  final String id;
  final String name;
  final String? description;
  final String? address;
  final String? phone;
  final String? email;
  final String? imageUrl;
  final String? logoUrl;
  final bool isActive;
  final String ownerId; // ID del dueño
  final Map<String, dynamic>? location; // Coordenadas GPS
  final String? category;
  final double? rating;
  final int? reviewCount;
  final String? openingHours; // Horarios de apertura
  final String? deliveryRadius; // Radio de entrega en km
  final double? minimumOrder; // Pedido mínimo
  final double? deliveryFee; // Tarifa de entrega
  final int? estimatedDeliveryTime; // Tiempo estimado en minutos
  final Map<String, dynamic>? settings; // Configuraciones del negocio
  final DateTime createdAt;
  final DateTime updatedAt;

  BusinessModel({
    required this.id,
    required this.name,
    this.description,
    this.address,
    this.phone,
    this.email,
    this.imageUrl,
    this.logoUrl,
    this.isActive = true,
    required this.ownerId,
    this.location,
    this.category,
    this.rating,
    this.reviewCount,
    this.openingHours,
    this.deliveryRadius,
    this.minimumOrder,
    this.deliveryFee,
    this.estimatedDeliveryTime,
    this.settings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      imageUrl: json['image_url'],
      logoUrl: json['logo_url'],
      isActive: json['is_active'] ?? true,
      ownerId: json['owner_id'] ?? '',
      location: json['location'] != null ? Map<String, dynamic>.from(json['location']) : null,
      category: json['category'],
      rating: json['rating']?.toDouble(),
      reviewCount: json['review_count'],
      openingHours: json['opening_hours'],
      deliveryRadius: json['delivery_radius'],
      minimumOrder: json['minimum_order']?.toDouble(),
      deliveryFee: json['delivery_fee']?.toDouble(),
      estimatedDeliveryTime: json['estimated_delivery_time'],
      settings: json['settings'] != null ? Map<String, dynamic>.from(json['settings']) : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'address': address,
      'phone': phone,
      'email': email,
      'image_url': imageUrl,
      'logo_url': logoUrl,
      'is_active': isActive,
      'owner_id': ownerId,
      'location': location,
      'category': category,
      'rating': rating,
      'review_count': reviewCount,
      'opening_hours': openingHours,
      'delivery_radius': deliveryRadius,
      'minimum_order': minimumOrder,
      'delivery_fee': deliveryFee,
      'estimated_delivery_time': estimatedDeliveryTime,
      'settings': settings,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  BusinessModel copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    String? phone,
    String? email,
    String? imageUrl,
    String? logoUrl,
    bool? isActive,
    String? ownerId,
    Map<String, dynamic>? location,
    String? category,
    double? rating,
    int? reviewCount,
    String? openingHours,
    String? deliveryRadius,
    double? minimumOrder,
    double? deliveryFee,
    int? estimatedDeliveryTime,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BusinessModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      isActive: isActive ?? this.isActive,
      ownerId: ownerId ?? this.ownerId,
      location: location ?? this.location,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      openingHours: openingHours ?? this.openingHours,
      deliveryRadius: deliveryRadius ?? this.deliveryRadius,
      minimumOrder: minimumOrder ?? this.minimumOrder,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      estimatedDeliveryTime: estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'BusinessModel(id: $id, name: $name, ownerId: $ownerId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BusinessModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 