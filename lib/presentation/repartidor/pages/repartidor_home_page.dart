import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../core/localization.dart';
import '../../../application/providers/auth_provider.dart';
import '../../../application/providers/order_provider.dart';
import '../../../core/router.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/loading_widget.dart';

class RepartidorHomePage extends StatefulWidget {
  const RepartidorHomePage({super.key});

  @override
  State<RepartidorHomePage> createState() => _RepartidorHomePageState();
}

class _RepartidorHomePageState extends State<RepartidorHomePage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    await orderProvider.loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Panel de Repartidor'),
        backgroundColor: AppTheme.repartidorColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () => AppRouter.goToRepartidorMap(context),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => AppRouter.goToRepartidorProfile(context),
          ),
        ],
      ),
      body: Consumer2<AuthProvider, OrderProvider>(
        builder: (context, authProvider, orderProvider, child) {
          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Saludo del repartidor
                  _buildWelcomeSection(authProvider),
                  
                  const SizedBox(height: 24),
                  
                  // Estadísticas del día
                  _buildDailyStatsSection(orderProvider),
                  
                  const SizedBox(height: 24),
                  
                  // Pedidos asignados
                  _buildAssignedOrdersSection(orderProvider),
                  
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
                color: AppTheme.repartidorColor,
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
              '¿Listo para las entregas de hoy?',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyStatsSection(OrderProvider orderProvider) {
    final today = DateTime.now();
    final todayOrders = orderProvider.orders.where((order) {
      final orderDate = DateTime.parse(order.createdAt);
      return orderDate.year == today.year &&
             orderDate.month == today.month &&
             orderDate.day == today.day;
    }).toList();
    
    final deliveredToday = todayOrders.where((order) => 
      order.status == AppConstants.orderStatusDelivered
    ).length;
    
    final pendingDeliveries = orderProvider.orders.where((order) => 
      order.status == AppConstants.orderStatusReady ||
      order.status == AppConstants.orderStatusDelivering
    ).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estadísticas del Día',
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
              icon: Icons.delivery_dining,
              title: 'Entregas Hoy',
              value: deliveredToday.toString(),
              color: AppTheme.successColor,
            ),
            _buildStatCard(
              icon: Icons.pending_actions,
              title: 'Pendientes',
              value: pendingDeliveries.toString(),
              color: AppTheme.warningColor,
            ),
            _buildStatCard(
              icon: Icons.today,
              title: 'Hoy',
              value: '${today.day}/${today.month}',
              color: AppTheme.primaryColor,
            ),
            _buildStatCard(
              icon: Icons.attach_money,
              title: 'Ganancias Hoy',
              value: '\$${_calculateTodayEarnings(todayOrders)}',
              color: AppTheme.repartidorColor,
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

  Widget _buildAssignedOrdersSection(OrderProvider orderProvider) {
    final assignedOrders = orderProvider.orders.where((order) => 
      order.status == AppConstants.orderStatusReady ||
      order.status == AppConstants.orderStatusDelivering
    ).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pedidos Asignados',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => AppRouter.goToRepartidorOrders(context),
              child: Text(
                'Ver todos',
                style: TextStyle(
                  color: AppTheme.repartidorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (orderProvider.isLoading)
          const LoadingWidget()
        else if (assignedOrders.isEmpty)
          _buildEmptyOrdersState()
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: assignedOrders.take(5).length,
            itemBuilder: (context, index) {
              final order = assignedOrders[index];
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
            Text(order.address ?? 'Sin dirección'),
            Text('\$${order.total.toStringAsFixed(2)}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.map),
              onPressed: () {
                // TODO: Abrir mapa con la ubicación
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () {
                // TODO: Navegar a detalles del pedido
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyOrdersState() {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.delivery_dining_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay pedidos asignados',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Los pedidos aparecerán aquí cuando estén listos',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
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
              icon: Icons.receipt_long,
              title: 'Mis Pedidos',
              color: AppTheme.repartidorColor,
              onTap: () => AppRouter.goToRepartidorOrders(context),
            ),
            _buildQuickActionCard(
              icon: Icons.map,
              title: 'Mapa',
              color: AppTheme.accentColor,
              onTap: () => AppRouter.goToRepartidorMap(context),
            ),
            _buildQuickActionCard(
              icon: Icons.history,
              title: 'Historial',
              color: AppTheme.secondaryColor,
              onTap: () {
                // TODO: Navegar a historial
              },
            ),
            _buildQuickActionCard(
              icon: Icons.person,
              title: 'Mi Perfil',
              color: AppTheme.primaryColor,
              onTap: () => AppRouter.goToRepartidorProfile(context),
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
      selectedItemColor: AppTheme.repartidorColor,
      unselectedItemColor: Colors.grey,
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 0:
            // Ya estamos en home
            break;
          case 1:
            AppRouter.goToRepartidorOrders(context);
            break;
          case 2:
            AppRouter.goToRepartidorMap(context);
            break;
          case 3:
            // TODO: Historial
            break;
          case 4:
            AppRouter.goToRepartidorProfile(context);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'Pedidos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Mapa',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history),
          label: 'Historial',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }

  String _calculateTodayEarnings(List<dynamic> todayOrders) {
    double total = 0;
    for (final order in todayOrders) {
      if (order.status == AppConstants.orderStatusDelivered) {
        // Asumiendo que el repartidor recibe un 10% del total
        total += order.total * 0.1;
      }
    }
    return total.toStringAsFixed(2);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.orderStatusReady:
        return AppTheme.successColor;
      case AppConstants.orderStatusDelivering:
        return AppTheme.repartidorColor;
      case AppConstants.orderStatusDelivered:
        return AppTheme.successColor;
      default:
        return AppTheme.textSecondaryColor;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case AppConstants.orderStatusReady:
        return Icons.check_circle;
      case AppConstants.orderStatusDelivering:
        return Icons.delivery_dining;
      case AppConstants.orderStatusDelivered:
        return Icons.done_all;
      default:
        return Icons.receipt;
    }
  }
} 