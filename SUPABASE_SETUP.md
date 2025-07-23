# Configuración de Supabase

## Pasos para configurar Supabase

### 1. Crear proyecto en Supabase

1. Ve a [https://supabase.com](https://supabase.com)
2. Crea una cuenta gratuita
3. Crea un nuevo proyecto
4. Espera a que se complete la configuración

### 2. Obtener credenciales

1. En tu proyecto de Supabase, ve a **Settings** > **API**
2. Copia la **URL** y la **anon key**
3. Actualiza `lib/config/supabase_config.dart` con tus credenciales:

```dart
static const String supabaseUrl = 'TU_URL_AQUI';
static const String supabaseAnonKey = 'TU_ANON_KEY_AQUI';
```

### 3. Crear la tabla en la base de datos

1. Ve a **SQL Editor** en tu proyecto de Supabase
2. Ejecuta el siguiente SQL para crear la tabla:

```sql
CREATE TABLE dishes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  category TEXT,
  image_url TEXT,
  is_available BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 4. Configurar políticas de seguridad (opcional)

Para permitir operaciones CRUD desde la app, ejecuta:

```sql
-- Permitir lectura para todos
CREATE POLICY "Allow public read access" ON dishes
FOR SELECT USING (true);

-- Permitir inserción para usuarios autenticados
CREATE POLICY "Allow authenticated insert" ON dishes
FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Permitir actualización para usuarios autenticados
CREATE POLICY "Allow authenticated update" ON dishes
FOR UPDATE USING (auth.role() = 'authenticated');

-- Permitir eliminación para usuarios autenticados
CREATE POLICY "Allow authenticated delete" ON dishes
FOR DELETE USING (auth.role() = 'authenticated');
```

### 5. Probar la aplicación

Una vez configurado, la aplicación debería funcionar correctamente con:
- ✅ Lista de platos
- ✅ Agregar nuevos platos
- ✅ Editar platos existentes
- ✅ Eliminar platos
- ✅ Cambiar disponibilidad
- ✅ Búsqueda de platos

## Ventajas de Supabase sobre Firebase

1. **Más moderno**: Basado en PostgreSQL
2. **Mejor rendimiento**: Consultas SQL nativas
3. **Más flexible**: SQL completo disponible
4. **Mejor documentación**: Más clara y completa
5. **Menos problemas de compatibilidad**: Especialmente con iOS
6. **Gratis**: Plan gratuito más generoso

## Solución de problemas

### Error de inicialización
Si ves "LateInitializationError", asegúrate de que:
1. Las credenciales estén correctas
2. La tabla `dishes` exista en la base de datos
3. Las políticas de seguridad permitan las operaciones

### Error de conexión
Si no puedes conectar:
1. Verifica que la URL y anon key sean correctas
2. Asegúrate de que el proyecto esté activo
3. Revisa la consola de Supabase para errores 