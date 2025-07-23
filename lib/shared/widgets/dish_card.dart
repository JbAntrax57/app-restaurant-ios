import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'custom_card.dart';

class DishCard extends StatelessWidget {
  final dynamic dish;
  final VoidCallback? onAddToCart;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showAddToCartButton;
  final bool showEditButton;
  final bool showDeleteButton;

  const DishCard({
    super.key,
    required this.dish,
    this.onAddToCart,
    this.onEdit,
    this.onDelete,
    this.showAddToCartButton = false,
    this.showEditButton = false,
    this.showDeleteButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Imagen del plato
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: dish.imageUrl != null
                  ? Image.network(
                      dish.imageUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.restaurant),
                        );
                      },
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.restaurant),
                    ),
            ),
            
            const SizedBox(width: 16),
            
            // Información del plato
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dish.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (dish.description != null) ...[
                    Text(
                      dish.description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                  ],
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          dish.category,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!dish.isAvailable)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'No disponible',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.errorColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${dish.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Botones de acción
            Column(
              children: [
                if (showAddToCartButton && dish.isAvailable)
                  IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    onPressed: onAddToCart,
                    color: AppTheme.clienteColor,
                    tooltip: 'Agregar al carrito',
                  ),
                if (showEditButton)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: onEdit,
                    color: AppTheme.duenioColor,
                    tooltip: 'Editar',
                  ),
                if (showDeleteButton)
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: onDelete,
                    color: AppTheme.errorColor,
                    tooltip: 'Eliminar',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 