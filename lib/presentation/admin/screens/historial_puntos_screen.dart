import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class HistorialPuntosScreen extends StatefulWidget {
  final Map<String, dynamic> dueno;

  const HistorialPuntosScreen({
    Key? key,
    required this.dueno,
  }) : super(key: key);

  @override
  State<HistorialPuntosScreen> createState() => _HistorialPuntosScreenState();
}

class _HistorialPuntosScreenState extends State<HistorialPuntosScreen> {
  late Future<List<Map<String, dynamic>>> _historialFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _historialFuture = _obtenerHistorialPuntos();
  }

  Future<List<Map<String, dynamic>>> _obtenerHistorialPuntos() async {
    try {
      print('🔄 Obteniendo historial de puntos para: ${widget.dueno['dueno_email']}');
      
      // Obtener el sistema_puntos_id para este dueño
      final sistemaPuntosData = await Supabase.instance.client
          .from('sistema_puntos')
          .select('id')
          .eq('dueno_id', widget.dueno['dueno_id'])
          .single();
      
      final sistemaPuntosId = sistemaPuntosData['id'];
      print('🔄 Sistema puntos ID: $sistemaPuntosId');
      
      // Obtener historial de asignaciones
      final result = await Supabase.instance.client
          .from('asignaciones_puntos')
          .select('''
            *,
            admin:admin_id(id, email, name)
          ''')
          .eq('sistema_puntos_id', sistemaPuntosId)
          .order('created_at', ascending: false);

      print('🔄 Historial obtenido: ${result.length} registros');
      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      print('❌ Error obteniendo historial: $e');
      return [];
    }
  }

  Future<void> _refrescarHistorial() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final nuevoHistorial = await _obtenerHistorialPuntos();
      setState(() {
        _historialFuture = Future.value(nuevoHistorial);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatearFecha(String? fecha) {
    if (fecha == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(fecha);
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return 'N/A';
    }
  }

  Color _obtenerColorOperacion(String tipoAsignacion) {
    switch (tipoAsignacion?.toLowerCase()) {
      case 'agregar':
        return Colors.green;
      case 'quitar':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Icon _obtenerIconoOperacion(String tipoAsignacion) {
    switch (tipoAsignacion?.toLowerCase()) {
      case 'agregar':
        return const Icon(Icons.add_circle, color: Colors.green);
      case 'quitar':
        return const Icon(Icons.remove_circle, color: Colors.red);
      default:
        return const Icon(Icons.help, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Puntos - ${widget.dueno['dueno_email']}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refrescarHistorial,
            tooltip: 'Refrescar',
          ),
        ],
      ),
      body: Column(
        children: [
          // Información del dueño
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dueño: ${widget.dueno['dueno_email']}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        'Puntos Disponibles',
                        '${widget.dueno['puntos_disponibles'] ?? 0}',
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInfoCard(
                        'Total Asignado',
                        '${widget.dueno['total_asignado'] ?? 0}',
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Lista de historial
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _historialFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar el historial',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _refrescarHistorial,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                final historial = snapshot.data ?? [];

                if (historial.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.history, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No hay historial de puntos',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Este dueño aún no tiene asignaciones de puntos',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: historial.length,
                  itemBuilder: (context, index) {
                    final asignacion = historial[index];
                    final puntos = asignacion['puntos_asignados'] ?? 0;
                    final tipo = asignacion['tipo_asignacion'] ?? '';
                    final motivo = asignacion['motivo'] ?? '';
                    final fecha = asignacion['created_at'];
                    final admin = asignacion['admin'];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: _obtenerIconoOperacion(tipo),
                        title: Row(
                          children: [
                            Text(
                              tipo == 'agregar' ? '+$puntos' : '$puntos',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _obtenerColorOperacion(tipo),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'puntos',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (motivo.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Motivo: $motivo',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              'Fecha: ${_formatearFecha(fecha)}',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                            if (admin != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Admin: ${admin['email'] ?? admin['name'] ?? 'N/A'}',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _obtenerColorOperacion(tipo).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            tipo.toUpperCase(),
                            style: TextStyle(
                              color: _obtenerColorOperacion(tipo),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String titulo, String valor, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
} 