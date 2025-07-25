# Sistema de Puntos - Documentación

## 📋 Descripción General

El Sistema de Puntos es una funcionalidad integral que permite a los administradores asignar puntos a los dueños de restaurantes. Estos puntos se consumen automáticamente con cada pedido, y cuando se agotan, los restaurantes se desactivan automáticamente.

## 🏗️ Arquitectura del Sistema

### Base de Datos

#### Tablas Principales

1. **`sistema_puntos`** - Tabla principal del sistema
   - `id` (UUID): Identificador único
   - `dueno_id` (UUID): Referencia al dueño
   - `puntos_disponibles` (INTEGER): Puntos actuales
   - `total_asignado` (INTEGER): Total de puntos asignados históricamente
   - `puntos_por_pedido` (INTEGER): Puntos que se consumen por pedido (default: 2)
   - `activo` (BOOLEAN): Estado del sistema
   - `fecha_ultima_asignacion` (TIMESTAMP): Última vez que se asignaron puntos
   - `fecha_ultimo_consumo` (TIMESTAMP): Última vez que se consumieron puntos

2. **`asignaciones_puntos`** - Historial de asignaciones
   - `id` (UUID): Identificador único
   - `sistema_puntos_id` (UUID): Referencia al sistema de puntos
   - `puntos_asignados` (INTEGER): Cantidad de puntos asignados/quitados
   - `tipo_asignacion` (TEXT): 'agregar', 'quitar', 'ajuste'
   - `motivo` (TEXT): Razón de la asignación
   - `admin_id` (UUID): Admin que realizó la operación

3. **`notificaciones_sistema`** - Sistema de notificaciones
   - `id` (UUID): Identificador único
   - `usuario_id` (UUID): Usuario destinatario
   - `tipo` (TEXT): Tipo de notificación
   - `titulo` (TEXT): Título de la notificación
   - `mensaje` (TEXT): Contenido de la notificación
   - `leida` (BOOLEAN): Estado de lectura
   - `enviada_push` (BOOLEAN): Si se envió notificación push

#### Vistas Útiles

- **`dashboard_puntos`**: Vista completa con información de dueños y puntos
- **`obtener_estadisticas_puntos()`**: Función que retorna estadísticas generales

### Funciones Principales

#### 1. `consumir_puntos_pedido(p_dueno_id, p_puntos_consumir)`
- **Propósito**: Consume puntos cuando se crea un pedido
- **Parámetros**:
  - `p_dueno_id`: ID del dueño
  - `p_puntos_consumir`: Puntos a consumir (default: 2)
- **Retorna**: `BOOLEAN` - true si se consumieron, false si no hay suficientes
- **Comportamiento**:
  - Crea sistema de puntos si no existe
  - Verifica si hay suficientes puntos
  - Consume puntos y actualiza fechas
  - Crea notificaciones si quedan pocos puntos o se agotan

#### 2. `asignar_puntos_dueno(p_dueno_id, p_puntos, p_tipo_asignacion, p_motivo, p_admin_id)`
- **Propósito**: Asigna o quita puntos a un dueño
- **Parámetros**:
  - `p_dueno_id`: ID del dueño
  - `p_puntos`: Cantidad de puntos
  - `p_tipo_asignacion`: 'agregar', 'quitar', 'ajuste'
  - `p_motivo`: Razón de la operación
  - `p_admin_id`: ID del admin que realiza la operación
- **Retorna**: `BOOLEAN` - true si se realizó correctamente
- **Comportamiento**:
  - Crea sistema de puntos si no existe
  - Actualiza puntos disponibles y total asignado
  - Registra la asignación en el historial
  - Crea notificación para el dueño

#### 3. `verificar_estado_restaurantes_por_puntos()`
- **Propósito**: Activa/desactiva restaurantes basado en puntos
- **Comportamiento**:
  - Desactiva restaurantes de dueños sin puntos
  - Activa restaurantes de dueños con puntos

## 🎯 Funcionalidades Implementadas

### Para Administradores

1. **Dashboard de Puntos**
   - KPIs: Total dueños, con/sin puntos, puntos disponibles
   - Configuración global de puntos por pedido
   - Estadísticas en tiempo real

2. **Gestión de Dueños**
   - Lista de todos los dueños con sus puntos
   - Estado visual (verde: con puntos, naranja: puntos bajos, rojo: sin puntos)
   - Asignación/quitada de puntos con motivo
   - Historial de operaciones

3. **Sistema de Notificaciones**
   - Notificaciones automáticas para puntos bajos
   - Notificaciones para puntos agotados
   - Historial de notificaciones del sistema
   - Marcado de notificaciones como leídas

### Para Dueños

1. **Verificación Automática**
   - Los puntos se consumen automáticamente con cada pedido
   - Notificaciones push y en-app cuando quedan pocos puntos
   - Desactivación automática de restaurantes sin puntos

2. **Transparencia**
   - Historial de asignaciones de puntos
   - Notificaciones de cambios en puntos
   - Estado actual de puntos disponibles

## 🔧 Integración con la Aplicación

### Flutter Implementation

#### Providers
- **`PuntosProvider`**: Maneja el estado del sistema de puntos
- **`PuntosService`**: Servicios para operaciones con puntos

#### Pantallas
- **`AdminConfiguracionSection`**: Dashboard completo para admins
  - 3 tabs: Dashboard, Dueños, Notificaciones
  - KPIs en tiempo real
  - Gestión de puntos por dueño
  - Sistema de notificaciones

### Uso en el Código

#### Consumir Puntos en Pedidos
```dart
// En el proceso de creación de pedidos
final puntosProvider = Provider.of<PuntosProvider>(context, listen: false);
final success = await puntosProvider.consumirPuntosPedido(duenoId, puntosConsumir: 2);

if (!success) {
  // Mostrar error: no hay suficientes puntos
}
```

#### Asignar Puntos (Admin)
```dart
// Desde la sección de configuración
final success = await puntosProvider.asignarPuntosDueno(
  duenoId,
  500,
  'agregar',
  'Recarga mensual',
);
```

#### Verificar Estado de Restaurante
```dart
// Antes de mostrar restaurantes
final isActive = await PuntosService.verificarRestauranteActivo(duenoId);
if (!isActive) {
  // Ocultar restaurante o mostrar mensaje
}
```

## 📊 Flujo de Trabajo

### 1. Configuración Inicial
1. Ejecutar `SISTEMA_PUNTOS_SETUP.sql` en Supabase
2. Verificar que las políticas RLS estén activas
3. Configurar notificaciones locales en la app

### 2. Operación Diaria
1. **Admin asigna puntos** → Se registra en `asignaciones_puntos`
2. **Cliente hace pedido** → Se consumen puntos automáticamente
3. **Sistema verifica puntos** → Crea notificaciones si es necesario
4. **Restaurantes se activan/desactivan** → Basado en puntos disponibles

### 3. Notificaciones
- **Puntos bajos** (≤50): Notificación de advertencia
- **Puntos agotados** (≤0): Notificación de desactivación
- **Nueva asignación**: Notificación al dueño

## 🔒 Seguridad

### Políticas RLS
- **Admins**: Acceso completo a todas las tablas
- **Dueños**: Solo pueden ver sus propios puntos y notificaciones
- **Clientes**: Sin acceso al sistema de puntos

### Validaciones
- Puntos no pueden ser negativos
- Solo admins pueden asignar/quitar puntos
- Verificación de permisos en cada operación

## 🚀 Próximas Mejoras

1. **Configuración Avanzada**
   - Puntos por categoría de restaurante
   - Bonificaciones por volumen de pedidos
   - Sistema de descuentos por puntos

2. **Analytics**
   - Gráficos de consumo de puntos
   - Predicciones de recargas necesarias
   - Reportes de rentabilidad por puntos

3. **Automatización**
   - Recargas automáticas programadas
   - Alertas proactivas para admins
   - Integración con sistemas de pago

## 📝 Notas Técnicas

### Dependencias
- `flutter_local_notifications`: Notificaciones push
- `supabase_flutter`: Base de datos
- `provider`: Estado de la aplicación

### Archivos Principales
- `SISTEMA_PUNTOS_SETUP.sql`: Script de base de datos
- `lib/presentation/admin/screens/configuracion_section.dart`: UI del admin
- `lib/application/providers/puntos_provider.dart`: Provider del estado
- `lib/services/puntos_service.dart`: Servicios de puntos

### Consideraciones de Performance
- Índices en campos frecuentemente consultados
- Vistas materializadas para estadísticas
- Paginación en listas grandes
- Caché de datos frecuentemente accedidos 