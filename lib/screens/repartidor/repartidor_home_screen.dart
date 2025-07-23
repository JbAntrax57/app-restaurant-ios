import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/supabase_service.dart';
import '../../models/dish.dart';
import '../../widgets/dish_card.dart';
import '../../widgets/loading_widget.dart';

class RepartidorHomeScreen extends StatefulWidget {
  const RepartidorHomeScreen({super.key});

  @override
  State<RepartidorHomeScreen> createState() => _RepartidorHomeScreenState();
}

class _RepartidorHomeScreenState extends State<RepartidorHomeScreen> {
  String _selectedStatus = 'Todos';
  final List<String> _statuses = [
    'Todos',
    'Pendientes',
    'En preparación',
    'Listos para entregar',
    'En camino',
    'Entregados',
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
        title: const Text('Panel del Repartidor'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: _showMap,
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

          final orders = _getMockOrders();

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.delivery_dining,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay pedidos pendientes',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Los nuevos pedidos aparecerán aquí',
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
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return OrderCard(
                order: order,
                onAccept: () => _acceptOrder(order),
                onStartDelivery: () => _startDelivery(order),
                onCompleteDelivery: () => _completeDelivery(order),
              );
            },
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _getMockOrders() {
    return [
      {
        'id': '1',
        'customerName': 'Juan Pérez',
        'address': 'Calle 123, Colonia Centro',
        'items': ['Pizza Margherita', 'Ensalada César'],
        'total': 29.99,
        'status': 'Pendientes',
        'time': '15:30',
      },
      {
        'id': '2',
        'customerName': 'María García',
        'address': 'Av. Principal 456, Colonia Norte',
        'items': ['Pasta Carbonara', 'Tiramisú'],
        'total': 42.50,
        'status': 'En preparación',
        'time': '15:45',
      },
      {
        'id': '3',
        'customerName': 'Carlos López',
        'address': 'Calle 789, Colonia Sur',
        'items': ['Hamburguesa Clásica', 'Papas Fritas'],
        'total': 18.75,
        'status': 'Listos para entregar',
        'time': '16:00',
      },
    ];
  }

  void _acceptOrder(Map<String, dynamic> order) {
    setState(() {
      order['status'] = 'En preparación';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pedido #${order['id']} aceptado'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _startDelivery(Map<String, dynamic> order) {
    setState(() {
      order['status'] = 'En camino';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Iniciando entrega del pedido #${order['id']}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _completeDelivery(Map<String, dynamic> order) {
    setState(() {
      order['status'] = 'Entregados';
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pedido #${order['id']} entregado exitosamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showMap() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mapa de Entregas'),
          content: Container(
            height: 300,
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Mapa de entregas',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Aquí se mostraría el mapa\ncon las rutas de entrega',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
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
          title: const Text('Filtrar por estado'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: _statuses.map((status) {
              return RadioListTile<String>(
                title: Text(status),
                value: status,
                groupValue: _selectedStatus,
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
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
}

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback? onAccept;
  final VoidCallback? onStartDelivery;
  final VoidCallback? onCompleteDelivery;

  const OrderCard({
    super.key,
    required this.order,
    this.onAccept,
    this.onStartDelivery,
    this.onCompleteDelivery,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pedido #${order['id']}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order['status']),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order['status'],
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
              'Cliente: ${order['customerName']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Dirección: ${order['address']}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Items: ${order['items'].join(', ')}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: \$${order['total']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Hora: ${order['time']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (order['status'] == 'Pendientes' && onAccept != null)
                  ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Aceptar'),
                  ),
                if (order['status'] == 'Listos para entregar' && onStartDelivery != null)
                  ElevatedButton(
                    onPressed: onStartDelivery,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Iniciar entrega'),
                  ),
                if (order['status'] == 'En camino' && onCompleteDelivery != null)
                  ElevatedButton(
                    onPressed: onCompleteDelivery,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Completar entrega'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pendientes':
        return Colors.orange;
      case 'En preparación':
        return Colors.blue;
      case 'Listos para entregar':
        return Colors.green;
      case 'En camino':
        return Colors.purple;
      case 'Entregados':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
} 