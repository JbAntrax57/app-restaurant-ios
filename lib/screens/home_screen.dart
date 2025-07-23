import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import '../models/dish.dart';
import 'add_edit_dish_screen.dart';
import '../widgets/dish_card.dart';
import '../widgets/loading_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'Todos';
  final List<String> _categories = [
    'Todos',
    'Entradas',
    'Platos Principales',
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
        title: const Text('Restaurant App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog();
            },
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
                    color: Colors.red[300],
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
                    'Agrega tu primer plato tocando el botón +',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Filtro de categorías
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category == _selectedCategory;
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        selectedColor: Theme.of(context).colorScheme.primaryContainer,
                      ),
                    );
                  },
                ),
              ),
              
              // Lista de platos
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: dishes.length,
                  itemBuilder: (context, index) {
                    final dish = dishes[index];
                    return DishCard(
                      dish: dish,
                      onEdit: () => _navigateToEditDish(dish),
                      onDelete: () => _showDeleteDialog(dish),
                      onToggleAvailability: () => _toggleAvailability(dish),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddDish(),
        tooltip: 'Agregar plato',
        child: const Icon(Icons.add),
      ),
    );
  }

  List<Dish> _getFilteredDishes(List<Dish> dishes) {
    if (_selectedCategory == 'Todos') {
      return dishes;
    }
    return dishes.where((dish) => dish.category == _selectedCategory).toList();
  }

  void _navigateToAddDish() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditDishScreen(),
      ),
    );
  }

  void _navigateToEditDish(Dish dish) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditDishScreen(dish: dish),
      ),
    );
  }

  void _showDeleteDialog(Dish dish) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar "${dish.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteDish(dish);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _deleteDish(Dish dish) async {
    final supabaseService = context.read<SupabaseService>();
    final success = await supabaseService.deleteDish(dish.id!);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${dish.name} eliminado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _toggleAvailability(Dish dish) async {
    final supabaseService = context.read<SupabaseService>();
    final success = await supabaseService.toggleDishAvailability(
      dish.id!,
      !dish.isAvailable,
    );
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            dish.isAvailable 
              ? '${dish.name} marcado como no disponible'
              : '${dish.name} marcado como disponible'
          ),
          backgroundColor: Colors.blue,
        ),
      );
    }
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
            results: results,
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
                  onEdit: () => _navigateToEditDish(context, dish),
                  onDelete: () => _showDeleteDialog(context, dish),
                  onToggleAvailability: () => _toggleAvailability(context, dish),
                );
              },
            ),
    );
  }

  void _navigateToEditDish(BuildContext context, Dish dish) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditDishScreen(dish: dish),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Dish dish) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que quieres eliminar "${dish.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteDish(context, dish);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _deleteDish(BuildContext context, Dish dish) async {
    final supabaseService = context.read<SupabaseService>();
    final success = await supabaseService.deleteDish(dish.id!);
    
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${dish.name} eliminado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _toggleAvailability(BuildContext context, Dish dish) async {
    final supabaseService = context.read<SupabaseService>();
    final success = await supabaseService.toggleDishAvailability(
      dish.id!,
      !dish.isAvailable,
    );
    
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            dish.isAvailable 
              ? '${dish.name} marcado como no disponible'
              : '${dish.name} marcado como disponible'
          ),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }
} 