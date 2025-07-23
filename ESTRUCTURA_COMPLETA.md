# 📱 ESTRUCTURA COMPLETA - APP DE RESTAURANTE CON SUPABASE

## 🏗️ ARQUITECTURA GENERAL

### Estructura de Carpetas (Replicada de movil/movil)
```
lib/
├── main.dart                    # Punto de entrada principal
├── core/                        # Configuraciones centrales
│   ├── router.dart             # Configuración de rutas (GoRouter)
│   ├── constants.dart          # Constantes de la aplicación
│   ├── theme.dart              # Tema de la aplicación
│   ├── env.dart                # Variables de entorno
│   ├── exceptions.dart         # Manejo de excepciones
│   ├── logger.dart             # Sistema de logging
│   └── localization.dart       # Internacionalización
├── presentation/               # Capa de presentación
│   ├── cliente/               # Pantallas del cliente
│   │   └── pages/
│   │       ├── cliente_home_page.dart
│   │       ├── cliente_menu_page.dart
│   │       ├── cliente_cart_page.dart
│   │       ├── cliente_orders_page.dart
│   │       └── cliente_profile_page.dart
│   ├── duenio/                # Pantallas del dueño
│   │   └── pages/
│   │       ├── duenio_home_page.dart
│   │       ├── duenio_menu_page.dart
│   │       ├── duenio_orders_page.dart
│   │       ├── duenio_analytics_page.dart
│   │       └── duenio_profile_page.dart
│   ├── repartidor/            # Pantallas del repartidor
│   │   └── pages/
│   │       ├── repartidor_home_page.dart
│   │       ├── repartidor_orders_page.dart
│   │       ├── repartidor_map_page.dart
│   │       └── repartidor_profile_page.dart
│   ├── admin/                 # Pantallas del administrador
│   │   └── pages/
│   │       ├── admin_home_page.dart
│   │       ├── admin_users_page.dart
│   │       ├── admin_settings_page.dart
│   │       └── admin_analytics_page.dart
│   └── common/                # Pantallas comunes
│       └── pages/
│           ├── splash_page.dart
│           ├── login_page.dart
│           └── error_page.dart
├── domain/                    # Capa de dominio
│   ├── entities/              # Entidades del dominio
│   │   ├── user_entity.dart
│   │   ├── dish_entity.dart
│   │   ├── order_entity.dart
│   │   └── cart_entity.dart
│   ├── repositories/          # Interfaces de repositorios
│   │   ├── auth_repository.dart
│   │   ├── dish_repository.dart
│   │   ├── order_repository.dart
│   │   └── user_repository.dart
│   └── usecases/             # Casos de uso
│       ├── auth_usecases.dart
│       ├── dish_usecases.dart
│       ├── order_usecases.dart
│       └── user_usecases.dart
├── data/                      # Capa de datos
│   ├── models/               # Modelos de datos
│   │   ├── user_model.dart
│   │   ├── dish_model.dart
│   │   ├── order_model.dart
│   │   └── cart_model.dart
│   ├── repositories/         # Implementaciones de repositorios
│   │   ├── supabase_repository.dart
│   │   ├── auth_repository_impl.dart
│   │   ├── dish_repository_impl.dart
│   │   ├── order_repository_impl.dart
│   │   └── user_repository_impl.dart
│   └── datasources/          # Fuentes de datos
│       ├── remote/
│       │   ├── supabase_datasource.dart
│       │   └── api_datasource.dart
│       └── local/
│           ├── cache_datasource.dart
│           └── preferences_datasource.dart
├── application/               # Capa de aplicación
│   ├── providers/            # Providers de estado
│   │   ├── auth_provider.dart
│   │   ├── dish_provider.dart
│   │   ├── order_provider.dart
│   │   └── user_provider.dart
│   └── services/             # Servicios de aplicación
│       ├── auth_service.dart
│       ├── dish_service.dart
│       ├── order_service.dart
│       ├── notification_service.dart
│       ├── location_service.dart
│       ├── payment_service.dart
│       └── analytics_service.dart
└── shared/                   # Componentes compartidos
    ├── utils/                # Utilidades
    │   ├── validators.dart
    │   ├── formatters.dart
    │   ├── extensions.dart
    │   └── helpers.dart
    └── widgets/              # Widgets reutilizables
        ├── custom_button.dart
        ├── custom_text_field.dart
        ├── custom_card.dart
        ├── loading_widget.dart
        ├── error_widget.dart
        └── dish_card.dart
```

## 🔄 MIGRACIÓN DE FIREBASE A SUPABASE

### Cambios Principales:

1. **Configuración de Base de Datos**
   - ❌ Firebase Firestore → ✅ Supabase PostgreSQL
   - ❌ Firebase Auth → ✅ Supabase Auth
   - ❌ Firebase Storage → ✅ Supabase Storage

2. **Archivos de Configuración**
   - ❌ `firebase_options.dart` → ✅ `env.dart`
   - ❌ `google-services.json` → ✅ Configuración en Supabase Dashboard

3. **Dependencias**
   ```yaml
   # Firebase (Anterior)
   firebase_core: ^2.24.2
   firebase_auth: ^4.15.3
   cloud_firestore: ^4.13.6
   firebase_storage: ^11.5.6
   
   # Supabase (Nuevo)
   supabase_flutter: ^2.8.0
   ```

4. **Inicialización**
   ```dart
   // Firebase (Anterior)
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   
   // Supabase (Nuevo)
   await Supabase.initialize(
     url: Env.supabaseUrl,
     anonKey: Env.supabaseAnonKey,
   );
   ```

## 🎨 TEMAS Y ESTILOS

### Colores por Rol:
- **Admin**: Rojo (#D32F2F)
- **Dueño**: Naranja (#FF9800)
- **Cliente**: Verde (#4CAF50)
- **Repartidor**: Azul (#2196F3)

### Temas:
- ✅ Tema claro y oscuro
- ✅ Material Design 3
- ✅ Colores personalizados por rol
- ✅ Tipografía consistente

## 🚀 FUNCIONALIDADES POR ROL

### 👤 Cliente
- ✅ Ver menú disponible
- ✅ Agregar al carrito
- ✅ Realizar pedidos
- ✅ Ver historial de pedidos
- ✅ Perfil personal
- ✅ Búsqueda de platos

### 👨‍💼 Dueño
- ✅ Gestión de platos (CRUD)
- ✅ Ver pedidos pendientes
- ✅ Analíticas del restaurante
- ✅ Control de disponibilidad
- ✅ Gestión de categorías

### 🚚 Repartidor
- ✅ Ver pedidos asignados
- ✅ Cambiar estado de pedidos
- ✅ Mapa de entregas
- ✅ Historial de entregas
- ✅ Perfil personal

### 👨‍💻 Admin
- ✅ Gestión completa de usuarios
- ✅ Gestión de platos
- ✅ Analíticas avanzadas
- ✅ Configuración del sistema
- ✅ Gestión de roles

## 📱 NAVEGACIÓN

### GoRouter Implementation:
```dart
// Rutas principales
'/cliente/home'     // Home del cliente
'/cliente/menu'     // Menú del cliente
'/cliente/cart'     // Carrito del cliente
'/cliente/orders'   // Pedidos del cliente

'/duenio/home'      // Home del dueño
'/duenio/menu'      // Gestión de menú
'/duenio/orders'    // Pedidos del restaurante
'/duenio/analytics' // Analíticas

'/repartidor/home'  // Home del repartidor
'/repartidor/orders' // Pedidos asignados
'/repartidor/map'   // Mapa de entregas

'/admin/home'       // Home del admin
'/admin/users'      // Gestión de usuarios
'/admin/settings'   // Configuración
'/admin/analytics'  // Analíticas avanzadas
```

## 🔧 CONFIGURACIÓN

### Variables de Entorno (env.dart):
```dart
// Supabase
static const String supabaseUrl = 'https://your-project.supabase.co';
static const String supabaseAnonKey = 'your-anon-key';

// Configuración de la app
static const String appName = 'Restaurant App';
static const String appVersion = '1.0.0';

// Configuración de desarrollo
static const bool isDevelopment = true;
static const bool enableLogging = true;
```

### Constantes (constants.dart):
```dart
// Rutas
static const String clienteHomeRoute = '/cliente/home';
static const String duenioHomeRoute = '/duenio/home';
static const String repartidorHomeRoute = '/repartidor/home';
static const String adminHomeRoute = '/admin/home';

// Estados de pedidos
static const String orderStatusPending = 'Pendiente';
static const String orderStatusPreparing = 'En preparación';
static const String orderStatusReady = 'Listo';
static const String orderStatusDelivering = 'En entrega';
static const String orderStatusDelivered = 'Entregado';
```

## 🛠️ HERRAMIENTAS Y SERVICIOS

### Logging (logger.dart):
```dart
AppLogger.info('Aplicación iniciada');
AppLogger.error('Error en la operación');
AppLogger.debug('Información de debug');
```

### Manejo de Excepciones (exceptions.dart):
```dart
throw NetworkException('Error de conexión');
throw AuthenticationException('Error de autenticación');
throw ValidationException('Datos inválidos');
```

### Internacionalización (localization.dart):
```dart
AppLocalization.getString('app_name');
AppLocalization.getStringWithParams('welcome', {'name': 'Juan'});
```

## 📊 BASE DE DATOS SUPABASE

### Tablas Principales:
```sql
-- Usuarios
CREATE TABLE users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  role TEXT NOT NULL,
  phone TEXT,
  address TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Platos
CREATE TABLE dishes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  category TEXT NOT NULL,
  image_url TEXT,
  is_available BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Pedidos
CREATE TABLE orders (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  status TEXT NOT NULL,
  total DECIMAL(10,2) NOT NULL,
  items JSONB NOT NULL,
  address TEXT,
  phone TEXT,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Carrito
CREATE TABLE cart_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  dish_id UUID REFERENCES dishes(id),
  quantity INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## 🚀 PRÓXIMOS PASOS

1. **Crear las páginas faltantes** en `presentation/`
2. **Implementar los providers** en `application/providers/`
3. **Crear los repositorios** en `data/repositories/`
4. **Implementar los servicios** en `application/services/`
5. **Configurar Supabase** con las tablas necesarias
6. **Probar cada rol** por separado
7. **Implementar autenticación** con Supabase Auth
8. **Agregar notificaciones** push
9. **Implementar pagos** (Stripe/PayPal)
10. **Agregar analytics** y crash reporting

## 💡 VENTAJAS DE LA NUEVA ESTRUCTURA

### ✅ Arquitectura Limpia
- Separación clara de responsabilidades
- Fácil mantenimiento y escalabilidad
- Testing más sencillo

### ✅ Supabase vs Firebase
- Mejor rendimiento con PostgreSQL
- SQL nativo más flexible
- Mejor documentación
- Menos problemas de compatibilidad

### ✅ GoRouter
- Navegación declarativa
- Deep linking automático
- Mejor gestión de estado de navegación

### ✅ Internacionalización
- Soporte multiidioma
- Fácil agregar nuevos idiomas
- Traducciones centralizadas

### ✅ Logging y Monitoreo
- Sistema de logging completo
- Manejo de excepciones robusto
- Fácil debugging

¿Te gustaría que continúe implementando alguna parte específica de la estructura? 