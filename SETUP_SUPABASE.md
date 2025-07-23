# 🚀 CONFIGURACIÓN DE SUPABASE

## 📋 Pasos para Configurar la Base de Datos

### 1. **Acceder al Dashboard de Supabase**
- Ve a: https://supabase.com/dashboard
- Inicia sesión con tu cuenta
- Selecciona tu proyecto: `yyjpkxrjwhaueanbteua`

### 2. **Ejecutar el Esquema SQL**
- Ve a la sección **SQL Editor** en el dashboard
- Crea un nuevo query
- Copia y pega todo el contenido del archivo `SUPABASE_SCHEMA.sql`
- Ejecuta el script completo

### 3. **Verificar las Tablas Creadas**
Después de ejecutar el script, deberías ver estas tablas:
- ✅ `users` - Usuarios con roles
- ✅ `businesses` - Negocios/restaurantes
- ✅ `dishes` - Platos del menú
- ✅ `categories` - Categorías de productos
- ✅ `orders` - Pedidos de clientes
- ✅ `notifications` - Notificaciones
- ✅ `reviews` - Reseñas

### 4. **Verificar los Datos Demo**
El script incluye datos de prueba:
- **4 usuarios demo** con diferentes roles
- **1 negocio demo** con información completa
- **5 platos demo** con categorías
- **Índices y políticas de seguridad**

### 5. **Configurar Variables de Entorno (Opcional)**
Si quieres usar variables de entorno en lugar de hardcodear las credenciales:

```bash
# En tu archivo .env o variables de sistema
SUPABASE_URL=https://yyjpkxrjwhaueanbteua.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl5anBreHJqd2hhdWVhbmJ0ZXVhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIyODUxODUsImV4cCI6MjA2Nzg2MTE4NX0.AqvEVE8Nln4qSIu-Tu0aNpwgK5at7i34vaSyaz9PWJE
```

## 🧪 **Probar la Conexión**

### 1. **Ejecutar la App**
```bash
flutter run
```

### 2. **Usuarios Demo Disponibles**
```
Cliente:    cliente@demo.com / 123456
Dueño:      duenio@demo.com / 123456
Repartidor: repartidor@demo.com / 123456
Admin:      admin@demo.com / 123456
```

### 3. **Funcionalidades a Probar**
- ✅ Login con diferentes roles
- ✅ Navegación entre páginas
- ✅ Gestión del carrito
- ✅ Filtros y búsqueda
- ✅ Estados de pedidos
- ✅ Temas por rol

## 🔧 **Configuración Adicional (Opcional)**

### **Habilitar Row Level Security (RLS)**
Las políticas RLS ya están incluidas en el script, pero puedes verificarlas en:
- Dashboard → Authentication → Policies

### **Configurar Storage (Para Imágenes)**
Si quieres subir imágenes:
1. Ve a Storage en el dashboard
2. Crea buckets para: `dishes`, `profiles`, `businesses`
3. Configura las políticas de acceso

### **Configurar Realtime**
Para actualizaciones en tiempo real:
1. Ve a Database → Replication
2. Habilita realtime para las tablas: `orders`, `dishes`

## 🐛 **Solución de Problemas**

### **Error de Conexión**
- Verifica que las credenciales sean correctas
- Asegúrate de que el proyecto esté activo
- Revisa los logs en la consola

### **Error de Permisos**
- Verifica que las políticas RLS estén habilitadas
- Revisa que los usuarios demo existan en la tabla `users`

### **Error de Tablas**
- Ejecuta el script SQL completo
- Verifica que todas las tablas se hayan creado
- Revisa los logs de SQL en el dashboard

## ✅ **Verificación Final**

Después de completar todos los pasos:

1. **La app debería iniciar sin errores**
2. **El login debería funcionar con usuarios demo**
3. **La navegación debería ser fluida**
4. **Los datos deberían cargar correctamente**
5. **Los temas deberían cambiar según el rol**

## 🎉 **¡Listo para Desarrollo!**

Una vez configurado, puedes:
- ✅ Desarrollar nuevas funcionalidades
- ✅ Agregar más páginas
- ✅ Implementar notificaciones push
- ✅ Integrar pagos
- ✅ Agregar mapas y geolocalización

**¡La migración está completa y la app está lista para usar!** 🚀 