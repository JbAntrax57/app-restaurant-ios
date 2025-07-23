import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../core/localization.dart';
import '../../../application/providers/auth_provider.dart';
import '../../../application/providers/order_provider.dart';
import '../../../application/providers/dish_provider.dart';
import '../../../core/router.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/loading_widget.dart';

class DuenioHomePage extends StatefulWidget {
  const DuenioHomePage({super.key});

  @override
  State<DuenioHomePage> createState() => _DuenioHomePageState();
}

class _DuenioHomePageState extends State<DuenioHomePage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final dishProvider = Provider.of<DishProvider>(context, listen: false);
    
    await Future.wait([
      orderProvider.loadOrders(),
      dishProvider.loadDishes(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppTheme.duenioColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => AppRouter.goToDuenioAnalytics(context),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => AppRouter.goToDuenioProfile(context),
          ),
        ],
      ),
      body: Consumer3<AuthProvider, OrderProvider, DishProvider>(
        builder: (context, authProvider, orderProvider, dishProvider, child) {
          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Saludo del dueño
                  _buildWelcomeSection(authProvider),
                  
                  const SizedBox(height: 24),
                  
                  // Estadísticas rápidas
                  _buildQuickStatsSection(orderProvider, dishProvider),
                  
                  const SizedBox(height: 24),
                  
                  // Pedidos pendientes
                  _buildPendingOrdersSection(orderProvider),
                  
                  const SizedBox(height: 24),
                  
                  // Acciones rápidas
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
                color: AppTheme.duenioColor,
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
              'Panel de control de tu negocio',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsSection(OrderProvider orderProvider, DishProvider dishProvider) {
    final pendingOrders = orderProvider.orders.where((order) => 
      order.status == AppConstants.orderStatusPending ||
      order.status == AppConstants.orderStatusPreparing
    ).length;
    
    final totalDishes = dishProvider.dishes.length;
    final availableDishes = dishProvider.dishes.where((dish) => dish.isAvailable).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estadísticas Rápidas',
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
          childAspectRatio: 1.2,
          children: [
            _buildStatCard(
              icon: Icons.pending_actions,
              title: 'Pedidos Pendientes',
              value: pendingOrders.toString(),
              color: AppTheme.warningColor,
            ),
            _buildStatCard(
              icon: Icons.restaurant_menu,
              title: 'Platos Disponibles',
              value: '$availableDishes/$totalDishes',
              color: AppTheme.successColor,
            ),
            _buildStatCard(
              icon: Icons.today,
              title: 'Hoy',
              value: '${DateTime.now().day}/${DateTime.now().month}',
              color: AppTheme.primaryColor,
            ),
            _buildStatCard(
              icon: Icons.attach_money,
              title: 'Ingresos Hoy',
              value: '\$${_calculateTodayEarnings(orderProvider)}',
              color: AppTheme.duenioColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return CustomCard(
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
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingOrdersSection(OrderProvider orderProvider) {
    final pendingOrders = orderProvider.orders.where((order) => 
      order.status == AppConstants.orderStatusPending ||
      order.status == AppConstants.orderStatusPreparing
    ).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pedidos Pendientes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => AppRouter.goToDuenioOrders(context),
              child: Text(
                'Ver todos',
                style: TextStyle(
                  color: AppTheme.duenioColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (orderProvider.isLoading)
          const LoadingWidget()
        else if (pendingOrders.isEmpty)
          _buildEmptyOrdersState()
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pendingOrders.take(3).length,
            itemBuilder: (context, index) {
              final order = pendingOrders[index];
              return _buildOrderCard(order);
            },
          ),
      ],
    );
  }

  Widget _buildOrderCard(dynamic order) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(order.status),
          child: Icon(
            _getStatusIcon(order.status),
            color: Colors.white,
          ),
        ),
        title: Text(
          'Pedido #${order.id.substring(0, 8)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(order.status),
            Text('\$${order.total.toStringAsFixed(2)}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () {
            // TODO: Navegar a detalles del pedido
          },
        ),
      ),
    );
  }

  Widget _buildEmptyOrdersState() {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay pedidos pendientes',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
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
              title: 'Gestionar Menú',
              color: AppTheme.duenioColor,
              onTap: () => AppRouter.goToDuenioMenu(context),
            ),
            _buildQuickActionCard(
              icon: Icons.receipt_long,
              title: 'Ver Pedidos',
              color: AppTheme.accentColor,
              onTap: () => AppRouter.goToDuenioOrders(context),
            ),
            _buildQuickActionCard(
              icon: Icons.analytics,
              title: 'Analíticas',
              color: AppTheme.secondaryColor,
              onTap: () => AppRouter.goToDuenioAnalytics(context),
            ),
            _buildQuickActionCard(
              icon: Icons.person,
              title: 'Mi Perfil',
              color: AppTheme.primaryColor,
              onTap: () => AppRouter.goToDuenioProfile(context),
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

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppTheme.duenioColor,
      unselectedItemColor: Colors.grey,
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 0:
            // Ya estamos en home
            break;
          case 1:
            AppRouter.goToDuenioMenu(context);
            break;
          case 2:
            AppRouter.goToDuenioOrders(context);
            break;
          case 3:
            AppRouter.goToDuenioAnalytics(context);
            break;
          case 4:
            AppRouter.goToDuenioProfile(context);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant_menu),
          label: 'Menú',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'Pedidos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Analíticas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }

  String _calculateTodayEarnings(OrderProvider orderProvider) {
    final today = DateTime.now();
    final todayOrders = orderProvider.orders.where((order) {
      final orderDate = DateTime.parse(order.createdAt);
      return orderDate.year == today.year &&
             orderDate.month == today.month &&
             orderDate.day == today.day;
    });
    
    double total = 0;
    for (final order in todayOrders) {
      total += order.total;
    }
    
    return total.toStringAsFixed(2);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.orderStatusPending:
        return AppTheme.warningColor;
      case AppConstants.orderStatusPreparing:
        return AppTheme.accentColor;
      case AppConstants.orderStatusReady:
        return AppTheme.successColor;
      case AppConstants.orderStatusDelivering:
        return AppTheme.primaryColor;
      case AppConstants.orderStatusDelivered:
        return AppTheme.successColor;
      default:
        return AppTheme.textSecondaryColor;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case AppConstants.orderStatusPending:
        return Icons.schedule;
      case AppConstants.orderStatusPreparing:
        return Icons.restaurant;
      case AppConstants.orderStatusReady:
        return Icons.check;
      case AppConstants.orderStatusDelivering:
        return Icons.delivery_dining;
      case AppConstants.orderStatusDelivered:
        return Icons.done_all;
      default:
        return Icons.receipt;
    }
  }
} 