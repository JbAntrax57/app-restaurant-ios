import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../core/localization.dart';
import '../../../application/providers/cart_provider.dart';
import '../../../application/providers/auth_provider.dart';
import '../../../core/router.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/loading_widget.dart';

class ClienteCartPage extends StatefulWidget {
  const ClienteCartPage({super.key});

  @override
  State<ClienteCartPage> createState() => _ClienteCartPageState();
}

class _ClienteCartPageState extends State<ClienteCartPage> {
  bool _isProcessingOrder = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(AppLocalization.getString('cart')),
        backgroundColor: AppTheme.clienteColor,
        foregroundColor: Colors.white,
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              if (cartProvider.items.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.clear_all),
                  onPressed: () => _showClearCartDialog(),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer2<CartProvider, AuthProvider>(
        builder: (context, cartProvider, authProvider, child) {
          if (cartProvider.isLoading) {
            return const LoadingWidget(message: 'Cargando carrito...');
          }

          if (cartProvider.items.isEmpty) {
            return _buildEmptyCartState();
          }

          return Column(
            children: [
              // Lista de items del carrito
              Expanded(
                child: _buildCartItemsList(cartProvider),
              ),
              
              // Resumen y botón de checkout
              _buildCheckoutSection(cartProvider, authProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItemsList(CartProvider cartProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cartProvider.items.length,
      itemBuilder: (context, index) {
        final cartItem = cartProvider.items[index];
        return _buildCartItemCard(cartItem, cartProvider);
      },
    );
  }

  Widget _buildCartItemCard(dynamic cartItem, CartProvider cartProvider) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Imagen del plato
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: cartItem.dish.imageUrl != null
                  ? Image.network(
                      cartItem.dish.imageUrl!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(Icons.restaurant),
                        );
                      },
                    )
                  : Container(
                      width: 60,
                      height: 60,
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
                    cartItem.dish.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cartItem.dish.description ?? '',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${(cartItem.dish.price * cartItem.quantity).toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppTheme.clienteColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Controles de cantidad
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        if (cartItem.quantity > 1) {
                          cartProvider.updateQuantity(cartItem.dish.id, cartItem.quantity - 1);
                        } else {
                          cartProvider.removeFromCart(cartItem.dish.id);
                        }
                      },
                      color: AppTheme.clienteColor,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.clienteColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${cartItem.quantity}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.clienteColor,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () {
                        cartProvider.updateQuantity(cartItem.dish.id, cartItem.quantity + 1);
                      },
                      color: AppTheme.clienteColor,
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _showRemoveItemDialog(cartItem.dish.id, cartItem.dish.name),
                  color: AppTheme.errorColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckoutSection(CartProvider cartProvider, AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Resumen del pedido
          _buildOrderSummary(cartProvider),
          
          const SizedBox(height: 16),
          
          // Botón de checkout
          CustomButton(
            onPressed: _isProcessingOrder ? null : () => _processOrder(cartProvider, authProvider),
            text: _isProcessingOrder ? 'Procesando...' : 'Realizar Pedido',
            isLoading: _isProcessingOrder,
            width: double.infinity,
            backgroundColor: AppTheme.clienteColor,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cartProvider) {
    final subtotal = cartProvider.total;
    final tax = subtotal * 0.16; // 16% IVA
    final deliveryFee = 2.50; // Tarifa de entrega fija
    final total = subtotal + tax + deliveryFee;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Subtotal'),
            Text('\$${subtotal.toStringAsFixed(2)}'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('IVA (16%)'),
            Text('\$${tax.toStringAsFixed(2)}'),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Costo de entrega'),
            Text('\$${deliveryFee.toStringAsFixed(2)}'),
          ],
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '\$${total.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.clienteColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyCartState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalization.getString('cart_empty'),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega algunos platos deliciosos',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            onPressed: () => AppRouter.goToClienteMenu(context),
            text: 'Ver Menú',
            backgroundColor: AppTheme.clienteColor,
          ),
        ],
      ),
    );
  }

  Future<void> _processOrder(CartProvider cartProvider, AuthProvider authProvider) async {
    if (authProvider.currentUser == null) {
      _showErrorSnackBar('Debes iniciar sesión para realizar un pedido');
      return;
    }

    setState(() {
      _isProcessingOrder = true;
    });

    try {
      // TODO: Implementar lógica de procesamiento de pedido
      await Future.delayed(const Duration(seconds: 2)); // Simulación
      
      // Limpiar carrito después del pedido exitoso
      cartProvider.clearCart();
      
      if (!mounted) return;
      
      _showSuccessSnackBar('Pedido realizado exitosamente');
      
      // Navegar a la página de pedidos
      AppRouter.goToClienteOrders(context);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Error al procesar el pedido: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingOrder = false;
        });
      }
    }
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vaciar carrito'),
        content: const Text('¿Estás seguro de que quieres vaciar el carrito?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<CartProvider>(context, listen: false).clearCart();
              Navigator.of(context).pop();
              _showSuccessSnackBar('Carrito vaciado');
            },
            child: const Text('Vaciar'),
          ),
        ],
      ),
    );
  }

  void _showRemoveItemDialog(String dishId, String dishName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar del carrito'),
        content: Text('¿Estás seguro de que quieres eliminar "$dishName" del carrito?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<CartProvider>(context, listen: false).removeFromCart(dishId);
              Navigator.of(context).pop();
              _showSuccessSnackBar('$dishName eliminado del carrito');
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
} 