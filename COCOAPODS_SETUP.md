# Configuración de CocoaPods

## ✅ Estado actual

### CocoaPods Global:
- **Versión**: 1.16.2
- **Estado**: ✅ Instalado y funcionando

### CocoaPods en el proyecto:

#### iOS:
- **Podfile**: ✅ Configurado
- **Podfile.lock**: ✅ Generado
- **Directorio Pods**: ✅ Creado
- **Versión mínima**: iOS 13.0
- **Dependencias instaladas**: 26 pods

#### macOS:
- **Podfile**: ✅ Configurado
- **Podfile.lock**: ✅ Generado
- **Directorio Pods**: ✅ Creado
- **Versión mínima**: macOS 10.15
- **Dependencias instaladas**: 25 pods

## 📦 Dependencias instaladas

### Firebase:
- `firebase_core` (3.15.1)
- `firebase_auth` (5.6.2)
- `cloud_firestore` (5.6.11)
- `firebase_storage` (12.4.9)

### Otras dependencias:
- `flutter_slidable` (3.1.2)
- `image_picker` (1.1.2)
- `provider` (6.1.5)
- `uuid` (4.5.1)
- `intl` (0.19.0)

## 🔧 Configuraciones realizadas

### iOS Podfile:
```ruby
platform :ios, '13.0'
```

### macOS Podfile:
```ruby
platform :osx, '10.15'
```

## 📁 Estructura de archivos

```
ios/
├── Podfile              # Configuración de CocoaPods
├── Podfile.lock         # Versiones bloqueadas
└── Pods/               # Dependencias instaladas

macos/
├── Podfile              # Configuración de CocoaPods
├── Podfile.lock         # Versiones bloqueadas
└── Pods/               # Dependencias instaladas
```

## 🚀 Comandos útiles

### Instalar dependencias:
```bash
# iOS
cd ios && pod install

# macOS
cd macos && pod install

# Flutter
flutter pub get
```

### Actualizar dependencias:
```bash
# iOS
cd ios && pod update

# macOS
cd macos && pod update

# Flutter
flutter pub upgrade
```

### Limpiar y reinstalar:
```bash
# iOS
cd ios && pod deintegrate && pod install

# macOS
cd macos && pod deintegrate && pod install

# Flutter
flutter clean && flutter pub get
```

## ⚠️ Notas importantes

1. **Versiones mínimas**: 
   - iOS: 13.0
   - macOS: 10.15

2. **Configuración de Xcode**: 
   - Asegúrate de abrir el archivo `.xcworkspace` en lugar de `.xcodeproj`
   - Para iOS: `ios/Runner.xcworkspace`
   - Para macOS: `macos/Runner.xcworkspace`

3. **Firebase**: 
   - Todas las dependencias de Firebase están correctamente instaladas
   - La configuración está lista para usar

## 🐛 Solución de problemas

### Error de versión mínima:
```bash
# Actualizar versión en Podfile
platform :ios, '13.0'  # Para iOS
platform :osx, '10.15' # Para macOS
```

### Error de dependencias:
```bash
# Limpiar y reinstalar
pod deintegrate
pod install
```

### Error de configuración:
```bash
# Verificar que estás usando .xcworkspace
open ios/Runner.xcworkspace
```

## ✅ Verificación

Para verificar que todo está funcionando:

1. **Ejecutar la aplicación**:
   ```bash
   flutter run -d ios
   flutter run -d macos
   ```

2. **Verificar dependencias**:
   ```bash
   flutter doctor
   pod --version
   ```

3. **Verificar archivos**:
   ```bash
   ls ios/Pods/
   ls macos/Pods/
   ``` 