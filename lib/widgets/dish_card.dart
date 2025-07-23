import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/dish.dart';

class DishCard extends StatelessWidget {
  final Dish dish;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleAvailability;
  final bool showAddToCart;
  final VoidCallback? onAddToCart;

  const DishCard({
    super.key,
    required this.dish,
    this.onEdit,
    this.onDelete,
    this.onToggleAvailability,
    this.showAddToCart = false,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final hasActions = onEdit != null || onDelete != null || onToggleAvailability != null;
    
    Widget cardContent = _buildCardContent();
    
    if (hasActions) {
      return Slidable(
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            if (onEdit != null)
              SlidableAction(
                onPressed: (_) => onEdit!(),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: Icons.edit,
                label: 'Editar',
              ),
            if (onDelete != null)
              SlidableAction(
                onPressed: (_) => onDelete!(),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Eliminar',
              ),
          ],
        ),
        child: cardContent,
      );
    }
    
      Widget _buildCardContent() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: dish.isAvailable ? Colors.transparent : Colors.grey[300]!,
          ),
        ),
        child: Opacity(
          opacity: dish.isAvailable ? 1.0 : 0.6,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  dish.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(dish.category),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  dish.category,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            dish.description,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${dish.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              dish.isAvailable 
                                ? Icons.check_circle 
                                : Icons.cancel,
                              size: 16,
                              color: dish.isAvailable 
                                ? Colors.green 
                                : Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dish.isAvailable ? 'Disponible' : 'No disponible',
                              style: TextStyle(
                                fontSize: 12,
                                color: dish.isAvailable 
                                  ? Colors.green 
                                  : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Creado: ${_formatDate(dish.createdAt)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    Row(
                      children: [
                        if (onToggleAvailability != null)
                          IconButton(
                            onPressed: onToggleAvailability,
                            icon: Icon(
                              dish.isAvailable 
                                ? Icons.visibility_off 
                                : Icons.visibility,
                              size: 20,
                            ),
                            tooltip: dish.isAvailable 
                              ? 'Marcar como no disponible'
                              : 'Marcar como disponible',
                          ),
                        if (onEdit != null)
                          IconButton(
                            onPressed: onEdit,
                            icon: const Icon(
                              Icons.edit,
                              size: 20,
                            ),
                            tooltip: 'Editar plato',
                          ),
                        if (showAddToCart && onAddToCart != null)
                          IconButton(
                            onPressed: onAddToCart,
                            icon: const Icon(
                              Icons.add_shopping_cart,
                              size: 20,
                            ),
                            tooltip: 'Agregar al carrito',
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Entradas':
        return Colors.orange;
      case 'Platos Principales':
        return Colors.blue;
      case 'Postres':
        return Colors.purple;
      case 'Bebidas':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
} 