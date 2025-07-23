import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../../core/localization.dart';
import '../../../application/providers/auth_provider.dart';
import '../../../application/providers/user_provider.dart';
import '../../../application/providers/order_provider.dart';
import '../../../core/router.dart';
import '../../../shared/widgets/custom_card.dart';
import '../../../shared/widgets/loading_widget.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    
    await Future.wait([
      userProvider.loadUsers(),
      orderProvider.loadOrders(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: AppTheme.adminColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => AppRouter.goToAdminAnalytics(context),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => AppRouter.goToAdminSettings(context),
          ),
        ],
      ),
      body: Consumer3<AuthProvider, UserProvider, OrderProvider>(
        builder: (context, authProvider, userProvider, orderProvider, child) {
          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Saludo del admin
                  _buildWelcomeSection(authProvider),
                  
                  const SizedBox(height: 24),
                  
                  // Estadísticas del sistema
                  _buildSystemStatsSection(userProvider, orderProvider),
                  
                  const SizedBox(height: 24),
                  
                  // Usuarios recientes
                  _buildRecentUsersSection(userProvider),
                  
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
                color: AppTheme.adminColor,
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
              'Panel de administración del sistema',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStatsSection(UserProvider userProvider, OrderProvider orderProvider) {
    final totalUsers = userProvider.users.length;
    final totalOrders = orderProvider.orders.length;
    final todayOrders = orderProvider.orders.where((order) {
      final orderDate = DateTime.parse(order.createdAt);
      final today = DateTime.now();
      return orderDate.year == today.year &&
             orderDate.month == today.month &&
             orderDate.day == today.day;
    }).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estadísticas del Sistema',
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
              icon: Icons.people,
              title: 'Total Usuarios',
              value: totalUsers.toString(),
              color: AppTheme.primaryColor,
            ),
            _buildStatCard(
              icon: Icons.receipt_long,
              title: 'Total Pedidos',
              value: totalOrders.toString(),
              color: AppTheme.accentColor,
            ),
            _buildStatCard(
              icon: Icons.today,
              title: 'Pedidos Hoy',
              value: todayOrders.toString(),
              color: AppTheme.successColor,
            ),
            _buildStatCard(
              icon: Icons.attach_money,
              title: 'Ingresos Hoy',
              value: '\$${_calculateTodayRevenue(orderProvider)}',
              color: AppTheme.adminColor,
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

  Widget _buildRecentUsersSection(UserProvider userProvider) {
    final recentUsers = userProvider.users.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Usuarios Recientes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => AppRouter.goToAdminUsers(context),
              child: Text(
                'Ver todos',
                style: TextStyle(
                  color: AppTheme.adminColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (userProvider.isLoading)
          const LoadingWidget()
        else if (recentUsers.isEmpty)
          _buildEmptyUsersState()
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentUsers.length,
            itemBuilder: (context, index) {
              final user = recentUsers[index];
              return _buildUserCard(user);
            },
          ),
      ],
    );
  }

  Widget _buildUserCard(dynamic user) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(user.role),
          child: Icon(
            _getRoleIcon(user.role),
            color: Colors.white,
          ),
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email),
            Text(user.role.toUpperCase()),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () {
            // TODO: Navegar a detalles del usuario
          },
        ),
      ),
    );
  }

  Widget _buildEmptyUsersState() {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay usuarios registrados',
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
              icon: Icons.people,
              title: 'Gestionar Usuarios',
              color: AppTheme.adminColor,
              onTap: () => AppRouter.goToAdminUsers(context),
            ),
            _buildQuickActionCard(
              icon: Icons.analytics,
              title: 'Analíticas',
              color: AppTheme.accentColor,
              onTap: () => AppRouter.goToAdminAnalytics(context),
            ),
            _buildQuickActionCard(
              icon: Icons.settings,
              title: 'Configuración',
              color: AppTheme.secondaryColor,
              onTap: () => AppRouter.goToAdminSettings(context),
            ),
            _buildQuickActionCard(
              icon: Icons.restaurant_menu,
              title: 'Gestionar Menús',
              color: AppTheme.primaryColor,
              onTap: () {
                // TODO: Navegar a gestión de menús
              },
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
      selectedItemColor: AppTheme.adminColor,
      unselectedItemColor: Colors.grey,
      currentIndex: 0,
      onTap: (index) {
        switch (index) {
          case 0:
            // Ya estamos en home
            break;
          case 1:
            AppRouter.goToAdminUsers(context);
            break;
          case 2:
            AppRouter.goToAdminAnalytics(context);
            break;
          case 3:
            AppRouter.goToAdminSettings(context);
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Usuarios',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Analíticas',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Configuración',
        ),
      ],
    );
  }

  String _calculateTodayRevenue(OrderProvider orderProvider) {
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

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppTheme.adminColor;
      case 'duenio':
      case 'dueño':
        return AppTheme.duenioColor;
      case 'cliente':
        return AppTheme.clienteColor;
      case 'repartidor':
        return AppTheme.repartidorColor;
      default:
        return AppTheme.textSecondaryColor;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'duenio':
      case 'dueño':
        return Icons.store;
      case 'cliente':
        return Icons.person;
      case 'repartidor':
        return Icons.delivery_dining;
      default:
        return Icons.person;
    }
  }
} 