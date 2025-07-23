import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../core/localization.dart';
import '../../../application/providers/dish_provider.dart';
import '../../../application/providers/cart_provider.dart';
import '../../../core/router.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/dish_card.dart';

class ClienteMenuPage extends StatefulWidget {
  const ClienteMenuPage({super.key});

  @override
  State<ClienteMenuPage> createState() => _ClienteMenuPageState();
}

class _ClienteMenuPageState extends State<ClienteMenuPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Todas';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDishes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDishes() async {
    final dishProvider = Provider.of<DishProvider>(context, listen: false);
    await dishProvider.loadDishes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(AppLocalization.getString('menu')),
        backgroundColor: AppTheme.clienteColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => AppRouter.goToClienteCart(context),
          ),
        ],
      ),
      body: Consumer2<DishProvider, CartProvider>(
        builder: (context, dishProvider, cartProvider, child) {
          return Column(
            children: [
              // Barra de búsqueda
              _buildSearchBar(),
              
              // Filtros de categorías
              _buildCategoryFilters(),
              
              // Lista de platos
              Expanded(
                child: _buildDishesList(dishProvider, cartProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar platos...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: ['Todas', ...AppConstants.dishCategories].length,
        itemBuilder: (context, index) {
          final category = ['Todas', ...AppConstants.dishCategories][index];
          final isSelected = category == _selectedCategory;
          
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: AppTheme.clienteColor.withOpacity(0.2),
              checkmarkColor: AppTheme.clienteColor,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.clienteColor : AppTheme.textPrimaryColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected ? AppTheme.clienteColor : Colors.grey[300]!,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDishesList(DishProvider dishProvider, CartProvider cartProvider) {
    if (dishProvider.isLoading) {
      return const LoadingWidget(message: 'Cargando menú...');
    }

    if (dishProvider.dishes.isEmpty) {
      return _buildEmptyState();
    }

    // Filtrar platos por categoría y búsqueda
    final filteredDishes = dishProvider.dishes.where((dish) {
      final matchesCategory = _selectedCategory == 'Todas' || 
                            dish.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty || 
                          dish.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          dish.description?.toLowerCase().contains(_searchQuery.toLowerCase()) == true;
      
      return matchesCategory && matchesSearch && dish.isAvailable;
    }).toList();

    if (filteredDishes.isEmpty) {
      return _buildNoResultsState();
    }

    return RefreshIndicator(
      onRefresh: _loadDishes,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredDishes.length,
        itemBuilder: (context, index) {
          final dish = filteredDishes[index];
          return DishCard(
            dish: dish,
            onAddToCart: () {
              cartProvider.addToCart(dish);
              _showAddedToCartSnackBar(dish.name);
            },
            showAddToCartButton: true,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay platos disponibles',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta más tarde',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No se encontraron resultados',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Intenta con otros filtros',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddedToCartSnackBar(String dishName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text('$dishName agregado al carrito'),
            ),
          ],
        ),
        backgroundColor: AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Ver carrito',
          textColor: Colors.white,
          onPressed: () => AppRouter.goToClienteCart(context),
        ),
      ),
    );
  }
} 