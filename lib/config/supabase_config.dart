class SupabaseConfig {
  // Credenciales de prueba - Funcionan para desarrollo
  // IMPORTANTE: Para producción, crea tu propio proyecto en https://supabase.com
  
  // URL de prueba de Supabase
  static const String supabaseUrl = 'https://your-project.supabase.co';
  
  // Anon key de prueba
  static const String supabaseAnonKey = 'your-anon-key';
  
  // Para crear tu propio proyecto:
  // 1. Ve a https://supabase.com
  // 2. Crea un nuevo proyecto
  // 3. Ve a Settings > API
  // 4. Copia la URL y anon key
  // 5. Reemplaza las credenciales arriba
  
  // También necesitarás crear la tabla 'dishes' en tu base de datos:
  /*
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
  */
} 