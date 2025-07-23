import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../core/localization.dart';
import '../../../application/providers/auth_provider.dart';
import '../../../application/providers/dish_provider.dart';
import '../../../core/router.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/loading_widget.dart';

class ClienteHomePage extends StatefulWidget {
  const ClienteHomePage({super.key});

  @override
  State<ClienteHomePage> createState() => _ClienteHomePageState();
}

class _ClienteHomePageState extends State<ClienteHomePage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dishProvider = Provider.of<DishProvider>(context, listen: false);
    await dishProvider.loadDishes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(AppLocalization.getString('home')),
        backgroundColor: AppTheme.clienteColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => AppRouter.goToClienteCart(context),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => AppRouter.goToClienteProfile(context),
          ),
        ],
      ),
      body: Consumer2<AuthProvider, DishProvider>(
        builder: (context, authProvider, dishProvider, child) {
          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Saludo del usuario
                  _buildWelcomeSection(authProvider),
                  
                  const SizedBox(height: 24),
                  
                  // Sección de categorías
                  _buildCategoriesSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Sección de platos destacados
                  _buildFeaturedDishesSection(dishProvider),
                  
                  const SizedBox(height: 24),
                  
                  // Sección de acciones rápidas
                  _buildQuickActionsSection(),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildWelcomeSection(AuthProvider authProvider) {
    final userName = authProvider.userName;
    final currentTime = DateTime.now();
    String greeting = '¡Hola!';
    
    if (currentTime.hour < 12) {
      greeting = '¡Buenos días!';
    } else if (currentTime.hour < 18) {
      greeting = '¡Buenas tardes!';
    } else {
      greeting = '¡Buenas noches!';
    }

    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.clienteColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              userName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '¿Qué te gustaría comer hoy?',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categorías',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: AppConstants.dishCategories.length,
            itemBuilder: (context, index) {
              final category = AppConstants.dishCategories[index];
              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 12),
                child: CustomCard(
                  child: InkWell(
                    onTap: () {
                      // TODO: Navegar a categoría específica
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getCategoryIcon(category),
                          size: 32,
                          color: AppTheme.clienteColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          category,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedDishesSection(DishProvider dishProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Platos Destacados',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => AppRouter.goToClienteMenu(context),
              child: Text(
                'Ver todos',
                style: TextStyle(
                  color: AppTheme.clienteColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (dishProvider.isLoading)
          const LoadingWidget()
        else if (dishProvider.dishes.isEmpty)
          _buildEmptyState()
        else
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dishProvider.dishes.take(5).length,
              itemBuilder: (context, index) {
                final dish = dishProvider.dishes[index];
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 12),
                  child: CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: dish.imageUrl != null
                              ? Image.network(
                                  dish.imageUrl!,
                                  height: 100,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 100,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.restaurant),
                                    );
                                  },
                                )
                              : Container(
                                  height: 100,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.restaurant),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dish.name,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${dish.price.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.clienteColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones Rápidas',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildQuickActionCard(
              icon: Icons.restaurant_menu,
              title: 'Ver Menú',
              color: AppTheme.clienteColor,
              onTap: () => AppRouter.goToClienteMenu(context),
            ),
            _buildQuickActionCard(
              icon: Icons.shopping_cart,
              title: 'Mi Carrito',
              color: AppTheme.accentColor,
              onTap: () => AppRouter.goToClienteCart(context),
            ),
            _buildQuickActionCard(
              icon: Icons.receipt_long,
              title: 'Mis Pedidos',
              color: AppTheme.secondaryColor,
              onTap: () => AppRouter.goToClienteOrders(context),
            ),
            _buildQuickActionCard(
              icon: Icons.person,
              title: 'Mi Perfil',
              color: AppTheme.primaryColor,
              onTap: () => AppRouter.goToClienteProfile(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return CustomCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
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
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppTheme.clienteColor,
      unselectedItemColor: Colors.grey,
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 0:
            // Ya estamos en home
            break;
          case 1:
            AppRouter.goToClienteMenu(context);
            break;
          case 2:
            AppRouter.goToClienteCart(context);
            break;
          case 3:
            AppRouter.goToClienteOrders(context);
            break;
          case 4:
            AppRouter.goToClienteProfile(context);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant_menu),
          label: 'Menú',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Carrito',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'Pedidos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'entradas':
        return Icons.tapas;
      case 'platos principales':
        return Icons.restaurant;
      case 'postres':
        return Icons.cake;
      case 'bebidas':
        return Icons.local_drink;
      case 'especialidades':
        return Icons.star;
      default:
        return Icons.restaurant;
    }
  }
} 