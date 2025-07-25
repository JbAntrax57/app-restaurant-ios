-- =====================================================
-- SCRIPT PARA CORREGIR POLÍTICAS RLS
-- =====================================================

-- 1. Verificar si las políticas existen
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'negocios_categorias';

-- 2. Eliminar políticas existentes si es necesario
DROP POLICY IF EXISTS "Anyone can view business categories" ON negocios_categorias;
DROP POLICY IF EXISTS "Business owners can manage their categories" ON negocios_categorias;
DROP POLICY IF EXISTS "Admins can manage all business categories" ON negocios_categorias;

-- 3. Crear políticas más permisivas para desarrollo
-- Política para permitir SELECT a todos
CREATE POLICY "Allow select for all" ON negocios_categorias
    FOR SELECT USING (true);

-- Política para permitir INSERT a todos (temporalmente para desarrollo)
CREATE POLICY "Allow insert for all" ON negocios_categorias
    FOR INSERT WITH CHECK (true);

-- Política para permitir UPDATE a todos (temporalmente para desarrollo)
CREATE POLICY "Allow update for all" ON negocios_categorias
    FOR UPDATE USING (true);

-- Política para permitir DELETE a todos (temporalmente para desarrollo)
CREATE POLICY "Allow delete for all" ON negocios_categorias
    FOR DELETE USING (true);

-- 4. Verificar que RLS esté habilitado
ALTER TABLE negocios_categorias ENABLE ROW LEVEL SECURITY;

-- 5. Verificar las políticas creadas
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual 
FROM pg_policies 
WHERE tablename = 'negocios_categorias';

-- =====================================================
-- ALTERNATIVA: Políticas más específicas (para producción)
-- =====================================================

/*
-- Si quieres políticas más específicas, descomenta estas líneas:

-- Política para admins
CREATE POLICY "Admins can do everything" ON negocios_categorias
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM usuarios 
            WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- Política para dueños de negocios
CREATE POLICY "Business owners can manage their categories" ON negocios_categorias
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM negocios 
            WHERE id = negocio_id AND usuarioid = auth.uid()
        )
    );

-- Política para lectura pública
CREATE POLICY "Public can view" ON negocios_categorias
    FOR SELECT USING (true);
*/ 