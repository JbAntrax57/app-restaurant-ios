# Configuración de Firebase para Restaurant App

## Pasos para configurar Firebase

### 1. Crear proyecto en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Crea un nuevo proyecto o selecciona uno existente
3. Habilita Firestore Database en tu proyecto

### 2. Configurar Firestore Database

1. En Firebase Console, ve a "Firestore Database"
2. Crea una base de datos en modo de prueba
3. Configura las reglas de seguridad:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /dishes/{document} {
      allow read, write: if true; // Para desarrollo - cambiar en producción
    }
  }
}
```

### 3. Configurar FlutterFire CLI

1. Instala FlutterFire CLI:
```bash
dart pub global activate flutterfire_cli
```

2. Ejecuta el comando de configuración:
```bash
flutterfire configure
```

3. Selecciona tu proyecto de Firebase y las plataformas (iOS, Android, Web)

### 4. Configurar archivos de configuración

#### Para iOS:
1. Descarga el archivo `GoogleService-Info.plist` desde Firebase Console
2. Agrégalo al proyecto iOS en `ios/Runner/GoogleService-Info.plist`

#### Para Android:
1. Descarga el archivo `google-services.json` desde Firebase Console
2. Agrégalo al proyecto Android en `android/app/google-services.json`

### 5. Configurar dependencias

Las dependencias ya están configuradas en `pubspec.yaml`:

```yaml
firebase_core: ^3.6.0
firebase_auth: ^5.3.1
cloud_firestore: ^5.4.0
firebase_storage: ^12.3.0
```

### 6. Ejecutar la aplicación

1. Ejecuta `flutter pub get` para instalar las dependencias
2. Ejecuta `flutter run` para iniciar la aplicación

## Funcionalidades implementadas

### CRUD Completo:
- **Create**: Agregar nuevos platos con formulario completo
- **Read**: Listar todos los platos con filtros por categoría
- **Update**: Editar platos existentes
- **Delete**: Eliminar platos con confirmación

### Características adicionales:
- Filtrado por categorías (Entradas, Platos Principales, Postres, Bebidas)
- Búsqueda de platos por nombre
- Control de disponibilidad (disponible/no disponible)
- Interfaz moderna con Material Design 3
- Gestos de deslizamiento para acciones rápidas
- Validación de formularios
- Manejo de estados de carga y errores

### Estructura de datos en Firestore:

```javascript
dishes: {
  [document_id]: {
    name: "Nombre del plato",
    description: "Descripción detallada",
    price: 15.99,
    category: "Platos Principales",
    imageUrl: "https://...", // Opcional
    isAvailable: true,
    createdAt: Timestamp,
    updatedAt: Timestamp
  }
}
```

## Notas importantes

1. **Seguridad**: Las reglas de Firestore están configuradas para permitir lectura/escritura sin autenticación para desarrollo. En producción, implementa autenticación y reglas de seguridad apropiadas.

2. **Configuración**: Asegúrate de que los archivos de configuración de Firebase estén correctamente ubicados en el proyecto.

3. **Dependencias**: Todas las dependencias necesarias ya están incluidas en el `pubspec.yaml`.

4. **Estructura del proyecto**: El código está organizado en carpetas:
   - `lib/models/`: Modelos de datos
   - `lib/services/`: Servicios de Firebase
   - `lib/screens/`: Pantallas de la aplicación
   - `lib/widgets/`: Widgets reutilizables

## Solución de problemas comunes

### Error de configuración de Firebase:
- Verifica que los archivos de configuración estén en las ubicaciones correctas
- Asegúrate de que el proyecto de Firebase esté correctamente configurado

### Error de dependencias:
- Ejecuta `flutter clean` y luego `flutter pub get`
- Verifica que las versiones de las dependencias sean compatibles

### Error de conexión a Firestore:
- Verifica las reglas de seguridad en Firebase Console
- Asegúrate de que la base de datos esté creada y habilitada 