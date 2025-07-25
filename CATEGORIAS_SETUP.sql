-- =====================================================
-- SETUP DE CATEGORÍAS PARA NEGOCIOS
-- =====================================================

-- Crear tabla de categorías principales
CREATE TABLE IF NOT EXISTS categorias_principales (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    icono VARCHAR(50),
    color VARCHAR(7) DEFAULT '#FF6B6B',
    activo BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Crear tabla intermedia para relación muchos a muchos
CREATE TABLE IF NOT EXISTS negocios_categorias (
    id SERIAL PRIMARY KEY,
    negocio_id UUID REFERENCES negocios(id) ON DELETE CASCADE,
    categoria_id INTEGER REFERENCES categorias_principales(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(negocio_id, categoria_id)
);

-- Crear índices para mejor rendimiento
CREATE INDEX IF NOT EXISTS idx_negocios_categorias_negocio_id ON negocios_categorias(negocio_id);
CREATE INDEX IF NOT EXISTS idx_negocios_categorias_categoria_id ON negocios_categorias(categoria_id);

-- Insertar categorías iniciales
INSERT INTO categorias_principales (nombre, descripcion, icono, color) VALUES
('Pizza', 'Restaurantes especializados en pizza italiana y variaciones', '🍕', '#FF6B6B'),
('Hamburguesas', 'Restaurantes de hamburguesas gourmet y fast food', '🍔', '#4ECDC4'),
('Sushi', 'Restaurantes japoneses especializados en sushi y sashimi', '🍣', '#45B7D1'),
('Mexicana', 'Restaurantes de comida mexicana tradicional', '🌮', '#FFA726'),
('China', 'Restaurantes de comida china y asiática', '🥡', '#FF7043'),
('Italiana', 'Restaurantes de pasta y comida italiana', '🍝', '#8E24AA'),
('Café', 'Cafeterías y tiendas de café', '☕', '#795548'),
('Postres', 'Pastelerías y tiendas de postres', '🍰', '#E91E63'),
('Mariscos', 'Restaurantes especializados en mariscos', '🦐', '#2196F3'),
('Vegetariana', 'Restaurantes con opciones vegetarianas y veganas', '🥗', '#4CAF50'),
('Pollo', 'Restaurantes especializados en pollo', '🍗', '#FF9800'),
('Pescado', 'Restaurantes de pescado fresco', '🐟', '#00BCD4'),
('Helados', 'Heladerías y tiendas de helados', '🍦', '#9C27B0'),
('Bebidas', 'Bares y tiendas de bebidas', '🍹', '#F44336'),
('Snacks', 'Tiendas de snacks y comida rápida', '🍿', '#607D8B')
ON CONFLICT (nombre) DO NOTHING;

-- Función para actualizar updated_at
CREATE OR REPLACE FUNCTION update_categorias_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger para actualizar updated_at en categorias_principales
DROP TRIGGER IF EXISTS update_categorias_principales_updated_at ON categorias_principales;
CREATE TRIGGER update_categorias_principales_updated_at 
    BEFORE UPDATE ON categorias_principales 
    FOR EACH ROW EXECUTE FUNCTION update_categorias_updated_at();

-- Habilitar RLS en las nuevas tablas
ALTER TABLE categorias_principales ENABLE ROW LEVEL SECURITY;
ALTER TABLE negocios_categorias ENABLE ROW LEVEL SECURITY;

-- Políticas de seguridad para categorias_principales
CREATE POLICY "Anyone can view active categories" ON categorias_principales
    FOR SELECT USING (activo = true);

CREATE POLICY "Admins can manage categories" ON categorias_principales
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM usuarios 
            WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- Políticas de seguridad para negocios_categorias
CREATE POLICY "Anyone can view business categories" ON negocios_categorias
    FOR SELECT USING (true);

CREATE POLICY "Business owners can manage their categories" ON negocios_categorias
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM negocios 
            WHERE id = negocio_id AND usuarioid = auth.uid()
        )
    );

CREATE POLICY "Admins can manage all business categories" ON negocios_categorias
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM usuarios 
            WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- =====================================================
-- MIGRACIÓN DE DATOS EXISTENTES (OPCIONAL)
-- =====================================================

-- Si ya tienes datos en la columna 'categoria' de negocios, migrarlos
-- Descomenta las siguientes líneas si necesitas migrar datos existentes:

/*
-- Migrar categorías existentes a la nueva tabla
INSERT INTO categorias_principales (nombre) 
SELECT DISTINCT categoria 
FROM negocios 
WHERE categoria IS NOT NULL 
AND categoria NOT IN (SELECT nombre FROM categorias_principales);

-- Crear las relaciones en la tabla intermedia
INSERT INTO negocios_categorias (negocio_id, categoria_id)
SELECT n.id, c.id
FROM negocios n
JOIN categorias_principales c ON n.categoria = c.nombre
WHERE n.categoria IS NOT NULL
ON CONFLICT (negocio_id, categoria_id) DO NOTHING;
*/

-- =====================================================
-- VISTAS ÚTILES
-- =====================================================

-- Vista para obtener negocios con sus categorías
CREATE OR REPLACE VIEW negocios_con_categorias AS
SELECT 
    n.*,
    array_agg(c.nombre) as categorias,
    array_agg(c.icono) as iconos_categorias,
    array_agg(c.color) as colores_categorias
FROM negocios n
LEFT JOIN negocios_categorias nc ON n.id = nc.negocio_id
LEFT JOIN categorias_principales c ON nc.categoria_id = c.id
WHERE c.activo = true OR c.activo IS NULL
GROUP BY n.id;

-- =====================================================
-- FUNCIONES ÚTILES
-- =====================================================

-- Función para agregar categoría a un negocio
CREATE OR REPLACE FUNCTION agregar_categoria_negocio(
    p_negocio_id UUID,
    p_categoria_id INTEGER
)
RETURNS BOOLEAN AS $$
BEGIN
    INSERT INTO negocios_categorias (negocio_id, categoria_id)
    VALUES (p_negocio_id, p_categoria_id)
    ON CONFLICT (negocio_id, categoria_id) DO NOTHING;
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- Función para remover categoría de un negocio
CREATE OR REPLACE FUNCTION remover_categoria_negocio(
    p_negocio_id UUID,
    p_categoria_id INTEGER
)
RETURNS BOOLEAN AS $$
BEGIN
    DELETE FROM negocios_categorias 
    WHERE negocio_id = p_negocio_id AND categoria_id = p_categoria_id;
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- COMENTARIOS FINALES
-- =====================================================

/*
ESTRUCTURA CREADA:

1. categorias_principales: Tabla principal de categorías
   - id (SERIAL), nombre, descripcion, icono, color, activo, timestamps

2. negocios_categorias: Tabla intermedia para relación muchos a muchos
   - negocio_id (UUID), categoria_id (INTEGER), timestamps

3. Índices para optimización de consultas

4. Políticas de seguridad RLS

5. Funciones útiles para gestión

6. Vista para consultas simplificadas

CATEGORÍAS INCLUIDAS:
- Pizza, Hamburguesas, Sushi (las que solicitaste)
- Plus categorías adicionales comunes

PRÓXIMOS PASOS:
1. Ejecutar este script en Supabase
2. Actualizar el código de la aplicación
3. Implementar selección múltiple de categorías
4. Probar las funcionalidades
*/ 