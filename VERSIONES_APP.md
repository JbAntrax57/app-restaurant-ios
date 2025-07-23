# Versiones de la Aplicación de Restaurante

Este proyecto contiene 4 versiones diferentes de la aplicación, cada una adaptada para un rol específico:

## 📱 Versiones Disponibles

### 1. **Admin** (`main_admin.dart`)
- **Color**: Rojo
- **Funcionalidades**:
  - Gestión completa de platos (CRUD)
  - Búsqueda y filtrado
  - Control de disponibilidad
  - Panel de administración

### 2. **Dueño** (`main_dueno.dart`)
- **Color**: Naranja
- **Funcionalidades**:
  - Gestión de platos
  - Analíticas del restaurante
  - Búsqueda y filtrado
  - Control de disponibilidad

### 3. **Cliente** (`main_cliente.dart`)
- **Color**: Verde
- **Funcionalidades**:
  - Ver menú disponible
  - Agregar al carrito
  - Realizar pedidos
  - Búsqueda de platos

### 4. **Repartidor** (`main_repartidor.dart`)
- **Color**: Azul
- **Funcionalidades**:
  - Ver pedidos pendientes
  - Aceptar entregas
  - Seguimiento de estado
  - Mapa de entregas

## 🚀 Cómo Ejecutar Cada Versión

### Para ejecutar la versión Admin:
```bash
flutter run -t lib/main_admin.dart
```

### Para ejecutar la versión Dueño:
```bash
flutter run -t lib/main_dueno.dart
```

### Para ejecutar la versión Cliente:
```bash
flutter run -t lib/main_cliente.dart
```

### Para ejecutar la versión Repartidor:
```bash
flutter run -t lib/main_repartidor.dart
```

## 📁 Estructura de Archivos

```
lib/
├── main.dart                    # Versión original
├── main_admin.dart             # Versión Admin
├── main_dueno.dart             # Versión Dueño
├── main_cliente.dart           # Versión Cliente
├── main_repartidor.dart        # Versión Repartidor
├── config/
│   └── supabase_config.dart    # Configuración de Supabase
├── services/
│   └── supabase_service.dart   # Servicio de base de datos
├── models/
│   └── dish.dart              # Modelo de plato
├── screens/
│   ├── home_screen.dart        # Pantalla principal original
│   ├── admin/
│   │   └── admin_home_screen.dart
│   ├── dueno/
│   │   └── dueno_home_screen.dart
│   ├── cliente/
│   │   └── cliente_home_screen.dart
│   └── repartidor/
│       └── repartidor_home_screen.dart
└── widgets/
    ├── dish_card.dart          # Widget de tarjeta de plato
    └── loading_widget.dart     # Widget de carga
```

## 🎨 Diferencias Visuales

Cada versión tiene su propio tema de color para fácil identificación:

- **Admin**: Rojo (#FF0000)
- **Dueño**: Naranja (#FF9800)
- **Cliente**: Verde (#4CAF50)
- **Repartidor**: Azul (#2196F3)

## 🔧 Configuración de Supabase

Todas las versiones usan la misma configuración de Supabase. Para configurar:

1. Ve a `lib/config/supabase_config.dart`
2. Reemplaza las credenciales con las de tu proyecto
3. Crea la tabla `dishes` en Supabase (ver `SUPABASE_SETUP.md`)

## 📋 Funcionalidades por Rol

### Admin
- ✅ Crear, editar, eliminar platos
- ✅ Cambiar disponibilidad
- ✅ Búsqueda y filtrado
- ✅ Gestión completa

### Dueño
- ✅ Crear, editar, eliminar platos
- ✅ Cambiar disponibilidad
- ✅ Ver analíticas
- ✅ Búsqueda y filtrado

### Cliente
- ✅ Ver menú disponible
- ✅ Agregar al carrito
- ✅ Realizar pedidos
- ✅ Búsqueda de platos
- ❌ No puede editar/eliminar

### Repartidor
- ✅ Ver pedidos pendientes
- ✅ Aceptar entregas
- ✅ Cambiar estado de pedidos
- ✅ Ver mapa de entregas
- ❌ No puede gestionar platos

## 🚀 Próximos Pasos

1. **Configurar Supabase**: Sigue las instrucciones en `SUPABASE_SETUP.md`
2. **Probar cada versión**: Ejecuta cada versión para verificar funcionamiento
3. **Personalizar**: Adapta las funcionalidades según tus necesidades
4. **Desplegar**: Compila para producción cada versión por separado

## 💡 Consejos

- Cada versión es independiente y puede ser desplegada por separado
- Comparten el mismo servicio de Supabase para consistencia de datos
- Los permisos se manejan a nivel de aplicación, no de base de datos
- Puedes agregar autenticación para mayor seguridad 