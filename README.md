# Restaurant App CRUD con Firebase

Una aplicación Flutter completa con sistema CRUD conectado a Firebase Firestore.

## 🚀 Características

### CRUD Completo:
- **CREATE** - Agregar nuevos platos con formulario completo
- **READ** - Listar platos con filtros por categoría
- **UPDATE** - Editar platos existentes
- **DELETE** - Eliminar platos con confirmación

### Funcionalidades adicionales:
- Filtrado por categorías (Entradas, Platos Principales, Postres, Bebidas)
- Búsqueda de platos por nombre
- Control de disponibilidad (disponible/no disponible)
- Interfaz moderna con Material Design 3
- Gestos de deslizamiento para acciones rápidas
- Validación de formularios
- Manejo de estados de carga y errores

## 🔧 Configuración

### Firebase ya configurado:
- **Proyecto ID**: `abonosapp-6507a`
- **Bundle ID**: `com.example.movil`
- **Archivos de configuración**: Ya incluidos en el proyecto

### Estructura del proyecto:
```
lib/
├── models/
│   └── dish.dart              # Modelo de datos
├── services/
│   └── firebase_service.dart  # Servicio Firebase
├── screens/
│   ├── home_screen.dart       # Pantalla principal
│   └── add_edit_dish_screen.dart # Formulario CRUD
├── widgets/
│   ├── dish_card.dart         # Tarjeta de plato
│   └── loading_widget.dart    # Widget de carga
├── firebase_options.dart      # Configuración Firebase
└── main.dart                  # Punto de entrada
```

## 📱 Ejecutar la aplicación

1. **Instalar dependencias:**
   ```bash
   flutter pub get
   ```

2. **Ejecutar en iOS:**
   ```bash
   flutter run -d ios
   ```

3. **Ejecutar en Android:**
   ```bash
   flutter run -d android
   ```

## 🗄️ Estructura de datos en Firestore

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

## 🎯 Funcionalidades implementadas

### Pantalla Principal (HomeScreen):
- Lista de platos con diseño de tarjetas
- Filtros por categoría
- Búsqueda de platos
- Gestos de deslizamiento para editar/eliminar
- Botón flotante para agregar nuevos platos

### Formulario CRUD (AddEditDishScreen):
- Campos validados (nombre, descripción, precio, categoría)
- Switch para controlar disponibilidad
- Botones para guardar/cancelar
- Manejo de estados de carga

### Servicio Firebase (FirebaseService):
- Operaciones CRUD completas
- Manejo de errores
- Estados de carga
- Búsqueda y filtrado
- Control de disponibilidad

## 🔒 Seguridad

**Nota importante**: Las reglas de Firestore están configuradas para permitir lectura/escritura sin autenticación para desarrollo. En producción, implementa autenticación y reglas de seguridad apropiadas.

## 🛠️ Tecnologías utilizadas

- **Flutter**: Framework de desarrollo
- **Firebase Firestore**: Base de datos en la nube
- **Provider**: Gestión de estado
- **Material Design 3**: Diseño de interfaz
- **Flutter Slidable**: Gestos de deslizamiento

## 📋 Próximos pasos

1. **Configurar reglas de seguridad** en Firebase Console
2. **Implementar autenticación** de usuarios
3. **Agregar subida de imágenes** para los platos
4. **Implementar notificaciones push**
5. **Agregar más funcionalidades** como pedidos, reservas, etc.

## 🐛 Solución de problemas

### Error de configuración de Firebase:
- Verifica que los archivos de configuración estén en las ubicaciones correctas
- Asegúrate de que el proyecto de Firebase esté correctamente configurado

### Error de dependencias:
- Ejecuta `flutter clean` y luego `flutter pub get`
- Verifica que las versiones de las dependencias sean compatibles

### Error de conexión a Firestore:
- Verifica las reglas de seguridad en Firebase Console
- Asegúrate de que la base de datos esté creada y habilitada

## 📞 Soporte

Si tienes problemas con la configuración o necesitas ayuda adicional, revisa:
1. La documentación de Firebase
2. Los logs de la aplicación
3. Las reglas de seguridad en Firebase Console

# Guía de instalación y ejecución en iOS 🚀

## 1. Verificar Ruby

Abre la terminal y ejecuta:
```bash
ruby --version
```
Debe mostrar una versión igual o superior a 3.1. Si tienes una versión antigua, actualiza Ruby usando rbenv:

```bash
brew install rbenv
rbenv install 3.2.8
rbenv global 3.2.8
source ~/.bash_profile  # o source ~/.zshrc si usas zsh
ruby --version          # Verifica que sea la nueva versión
```

## 2. Instalar CocoaPods

Instala CocoaPods con:
```bash
gem install cocoapods
```
Verifica la instalación:
```bash
pod --version
```

Si el comando `pod` no se reconoce, asegúrate de tener inicializado rbenv:
```bash
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile  # o ~/.zshrc
source ~/.bash_profile  # o source ~/.zshrc
```

## 3. Instalar dependencias de iOS

Desde la carpeta raíz del proyecto, entra a la carpeta ios y ejecuta:
```bash
cd ios
pod install
```

## 4. Correr el simulador y la app Flutter

Regresa a la raíz del proyecto:
```bash
cd ..
```
Abre el simulador de iOS (opcional):
```bash
open -a Simulator
```
Ejecuta la app en el simulador:
```bash
flutter run
```

Si tienes varios dispositivos, puedes verlos con:
```bash
flutter devices
```
Y seleccionar uno con:
```bash
flutter run -d <ID_DEL_DISPOSITIVO>
```

---

¿Tienes dudas o necesitas más pasos? ¡Revisa esta guía o pregunta a tu equipo!
