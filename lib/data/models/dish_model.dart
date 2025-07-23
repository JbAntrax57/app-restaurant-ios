class DishModel {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String category;
  final String? imageUrl;
  final bool isAvailable;
  final String? businessId; // Referencia al negocio
  final Map<String, dynamic>? extras; // Ingredientes extra, opciones, etc.
  final int? preparationTime; // Tiempo de preparación en minutos
  final bool isFeatured; // Si es un plato destacado
  final DateTime createdAt;
  final DateTime updatedAt;

  DishModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.category,
    this.imageUrl,
    this.isAvailable = true,
    this.businessId,
    this.extras,
    this.preparationTime,
    this.isFeatured = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DishModel.fromJson(Map<String, dynamic> json) {
    return DishModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] ?? 0.0).toDouble(),
      category: json['category'] ?? '',
      imageUrl: json['image_url'],
      isAvailable: json['is_available'] ?? true,
      businessId: json['business_id'],
      extras: json['extras'] != null ? Map<String, dynamic>.from(json['extras']) : null,
      preparationTime: json['preparation_time'],
      isFeatured: json['is_featured'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'business_id': businessId,
      'extras': extras,
      'preparation_time': preparationTime,
      'is_featured': isFeatured,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  DishModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? category,
    String? imageUrl,
    bool? isAvailable,
    String? businessId,
    Map<String, dynamic>? extras,
    int? preparationTime,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DishModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      businessId: businessId ?? this.businessId,
      extras: extras ?? this.extras,
      preparationTime: preparationTime ?? this.preparationTime,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'DishModel(id: $id, name: $name, price: $price, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DishModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 