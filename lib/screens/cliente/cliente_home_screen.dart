import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/supabase_service.dart';
import '../../models/dish.dart';
import '../../widgets/dish_card.dart';
import '../../widgets/loading_widget.dart';

class ClienteHomeScreen extends StatefulWidget {
  const ClienteHomeScreen({super.key});

  @override
  State<ClienteHomeScreen> createState() => _ClienteHomeScreenState();
}

class _ClienteHomeScreenState extends State<ClienteHomeScreen> {
  String _selectedCategory = 'Todos';
  final List<String> _categories = [
    'Todos',
    'Entradas',
    'Platos principales',
    'Postres',
    'Bebidas',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupabaseService>().getDishes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú del Restaurante'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: _showCart,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Consumer<SupabaseService>(
        builder: (context, supabaseService, child) {
          if (supabaseService.isLoading) {
            return const LoadingWidget();
          }

          if (supabaseService.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    supabaseService.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      supabaseService.getDishes();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final dishes = _getFilteredDishes(supabaseService.dishes);

          if (dishes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay platos disponibles',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vuelve más tarde',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dishes.length,
            itemBuilder: (context, index) {
              final dish = dishes[index];
              return DishCard(
                dish: dish,
                onEdit: null, // Cliente no puede editar
                onDelete: null, // Cliente no puede eliminar
                onToggleAvailability: null, // Cliente no puede cambiar disponibilidad
                showAddToCart: true, // Mostrar botón de agregar al carrito
                onAddToCart: () => _addToCart(dish),
              );
            },
          );
        },
      ),
    );
  }

  List<Dish> _getFilteredDishes(List<Dish> dishes) {
    if (_selectedCategory == 'Todos') {
      return dishes.where((dish) => dish.isAvailable).toList();
    }
    return dishes.where((dish) => 
      dish.category == _selectedCategory && dish.isAvailable
    ).toList();
  }

  void _addToCart(Dish dish) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${dish.name} agregado al carrito'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Ver carrito',
          onPressed: _showCart,
        ),
      ),
    );
  }

  void _showCart() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Carrito de Compras'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.shopping_cart),
                title: Text('Pizza Margherita'),
                subtitle: Text('\$12.99'),
                trailing: Text('x1'),
              ),
              ListTile(
                leading: Icon(Icons.shopping_cart),
                title: Text('Ensalada César'),
                subtitle: Text('\$8.50'),
                trailing: Text('x2'),
              ),
              Divider(),
              ListTile(
                title: Text('Total'),
                subtitle: Text('\$29.99'),
                trailing: Text('3 items'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Seguir comprando'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showOrderConfirmation();
              },
              child: const Text('Realizar pedido'),
            ),
          ],
        );
      },
    );
  }

  void _showOrderConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Pedido'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('¿Deseas confirmar tu pedido?'),
              SizedBox(height: 16),
              Text('Total: \$29.99'),
              Text('Tiempo estimado: 25-30 minutos'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _confirmOrder();
              },
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  void _confirmOrder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Pedido confirmado! Te notificaremos cuando esté listo.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController searchController = TextEditingController();
        
        return AlertDialog(
          title: const Text('Buscar platos'),
          content: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              labelText: 'Nombre del plato',
              hintText: 'Escribe para buscar...',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _searchDishes(searchController.text);
              },
              child: const Text('Buscar'),
            ),
          ],
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Filtrar por categoría'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _categories.map((category) {
              return RadioListTile<String>(
                title: Text(category),
                value: category,
                groupValue: _selectedCategory,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _searchDishes(String query) async {
    if (query.trim().isEmpty) return;
    
    final supabaseService = context.read<SupabaseService>();
    final results = await supabaseService.searchDishes(query);
    
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultsScreen(
            query: query,
            results: results.where((dish) => dish.isAvailable).toList(),
          ),
        ),
      );
    }
  }
}

class SearchResultsScreen extends StatelessWidget {
  final String query;
  final List<Dish> results;

  const SearchResultsScreen({
    super.key,
    required this.query,
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resultados para "$query"'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: results.isEmpty
          ? Center(
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
                    'No se encontraron resultados para "$query"',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final dish = results[index];
                return DishCard(
                  dish: dish,
                  onEdit: null,
                  onDelete: null,
                  onToggleAvailability: null,
                  showAddToCart: true,
                  onAddToCart: () => _addToCart(context, dish),
                );
              },
            ),
    );
  }

  void _addToCart(BuildContext context, Dish dish) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${dish.name} agregado al carrito'),
        backgroundColor: Colors.green,
      ),
    );
  }
} 