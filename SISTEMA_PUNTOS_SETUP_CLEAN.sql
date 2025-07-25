-- =====================================================
-- SCRIPT PARA SISTEMA DE PUNTOS (VERSIÓN LIMPIA)
-- =====================================================

-- LIMPIAR TODO PRIMERO
-- =====================================================

-- 1. Eliminar políticas RLS
DROP POLICY IF EXISTS "Admins can manage all points" ON sistema_puntos;
DROP POLICY IF EXISTS "Owners can view their own points" ON sistema_puntos;
DROP POLICY IF EXISTS "Admins can manage all assignments" ON asignaciones_puntos;
DROP POLICY IF EXISTS "Owners can view their own assignments" ON asignaciones_puntos;
DROP POLICY IF EXISTS "Users can view their own notifications" ON notificaciones_sistema;
DROP POLICY IF EXISTS "Admins can manage all notifications" ON notificaciones_sistema;

-- 2. Eliminar triggers
DROP TRIGGER IF EXISTS update_sistema_puntos_updated_at ON sistema_puntos;

-- 3. Eliminar funciones
DROP FUNCTION IF EXISTS obtener_estadisticas_puntos();
DROP FUNCTION IF EXISTS asignar_puntos_dueno(UUID, INTEGER, TEXT, TEXT, UUID);
DROP FUNCTION IF EXISTS asignar_puntos_dueno(UUID, INTEGER, TEXT, TEXT);
DROP FUNCTION IF EXISTS asignar_puntos_dueno(UUID, INTEGER, TEXT);
DROP FUNCTION IF EXISTS asignar_puntos_dueno(UUID, INTEGER);
DROP FUNCTION IF EXISTS asignar_puntos_dueno(UUID);
DROP FUNCTION IF EXISTS consumir_puntos_pedido(UUID, INTEGER);
DROP FUNCTION IF EXISTS consumir_puntos_pedido(UUID);
DROP FUNCTION IF EXISTS verificar_estado_restaurantes_por_puntos();
DROP FUNCTION IF EXISTS update_sistema_puntos_updated_at();

-- 4. Eliminar vistas
DROP VIEW IF EXISTS dashboard_puntos;

-- 5. Eliminar índices
DROP INDEX IF EXISTS idx_sistema_puntos_dueno_id;
DROP INDEX IF EXISTS idx_sistema_puntos_activo;
DROP INDEX IF EXISTS idx_asignaciones_puntos_sistema_id;
DROP INDEX IF EXISTS idx_asignaciones_puntos_admin_id;
DROP INDEX IF EXISTS idx_notificaciones_usuario_id;
DROP INDEX IF EXISTS idx_notificaciones_leida;

-- 6. Eliminar tablas (en orden correcto por dependencias)
DROP TABLE IF EXISTS notificaciones_sistema;
DROP TABLE IF EXISTS asignaciones_puntos;
DROP TABLE IF EXISTS sistema_puntos;

-- CREAR TODO DESDE CERO
-- =====================================================

-- 1. Tabla principal del sistema de puntos
CREATE TABLE sistema_puntos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dueno_id UUID REFERENCES usuarios(id) NOT NULL,
    puntos_disponibles INTEGER DEFAULT 0,
    total_asignado INTEGER DEFAULT 0,
    puntos_por_pedido INTEGER DEFAULT 2,
    activo BOOLEAN DEFAULT true,
    fecha_ultima_asignacion TIMESTAMP,
    fecha_ultimo_consumo TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(dueno_id)
);

-- 2. Tabla de asignaciones de puntos
CREATE TABLE asignaciones_puntos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sistema_puntos_id UUID REFERENCES sistema_puntos(id) ON DELETE CASCADE,
    puntos_asignados INTEGER NOT NULL,
    tipo_asignacion TEXT CHECK (tipo_asignacion IN ('agregar', 'quitar', 'ajuste')),
    motivo TEXT,
    admin_id UUID REFERENCES usuarios(id),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 3. Tabla de notificaciones del sistema
CREATE TABLE notificaciones_sistema (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID REFERENCES usuarios(id) ON DELETE CASCADE,
    tipo TEXT CHECK (tipo IN ('puntos_bajos', 'puntos_agotados', 'asignacion_puntos', 'restaurante_desactivado')),
    titulo TEXT NOT NULL,
    mensaje TEXT NOT NULL,
    leida BOOLEAN DEFAULT false,
    enviada_push BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 4. Índices para optimización
CREATE INDEX idx_sistema_puntos_dueno_id ON sistema_puntos(dueno_id);
CREATE INDEX idx_sistema_puntos_activo ON sistema_puntos(activo);
CREATE INDEX idx_asignaciones_puntos_sistema_id ON asignaciones_puntos(sistema_puntos_id);
CREATE INDEX idx_asignaciones_puntos_admin_id ON asignaciones_puntos(admin_id);
CREATE INDEX idx_notificaciones_usuario_id ON notificaciones_sistema(usuario_id);
CREATE INDEX idx_notificaciones_leida ON notificaciones_sistema(leida);

-- 5. Función para actualizar updated_at
CREATE FUNCTION update_sistema_puntos_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 6. Trigger para updated_at
CREATE TRIGGER update_sistema_puntos_updated_at 
    BEFORE UPDATE ON sistema_puntos 
    FOR EACH ROW EXECUTE FUNCTION update_sistema_puntos_updated_at();

-- 7. Función para consumir puntos en pedidos
CREATE FUNCTION consumir_puntos_pedido(
    p_dueno_id UUID,
    p_puntos_consumir INTEGER DEFAULT 2
)
RETURNS BOOLEAN AS $$
DECLARE
    puntos_actuales INTEGER;
    sistema_puntos_id UUID;
BEGIN
    -- Obtener el sistema de puntos del dueño
    SELECT id, puntos_disponibles 
    INTO sistema_puntos_id, puntos_actuales
    FROM sistema_puntos 
    WHERE dueno_id = p_dueno_id;
    
    -- Si no existe sistema de puntos, crearlo
    IF sistema_puntos_id IS NULL THEN
        INSERT INTO sistema_puntos (dueno_id, puntos_disponibles, total_asignado)
        VALUES (p_dueno_id, 0, 0)
        RETURNING id INTO sistema_puntos_id;
        puntos_actuales := 0;
    END IF;
    
    -- Verificar si hay suficientes puntos
    IF puntos_actuales < p_puntos_consumir THEN
        RETURN false; -- No hay suficientes puntos
    END IF;
    
    -- Consumir puntos
    UPDATE sistema_puntos 
    SET 
        puntos_disponibles = puntos_disponibles - p_puntos_consumir,
        fecha_ultimo_consumo = NOW()
    WHERE id = sistema_puntos_id;
    
    -- Crear notificación si quedan pocos puntos
    IF (puntos_actuales - p_puntos_consumir) <= 50 AND (puntos_actuales - p_puntos_consumir) > 0 THEN
        INSERT INTO notificaciones_sistema (usuario_id, tipo, titulo, mensaje)
        VALUES (p_dueno_id, 'puntos_bajos', 'Puntos Bajos', 
                'Te quedan ' || (puntos_actuales - p_puntos_consumir) || ' puntos. Considera recargar.');
    END IF;
    
    -- Si se quedó sin puntos, crear notificación
    IF (puntos_actuales - p_puntos_consumir) <= 0 THEN
        INSERT INTO notificaciones_sistema (usuario_id, tipo, titulo, mensaje)
        VALUES (p_dueno_id, 'puntos_agotados', 'Puntos Agotados', 
                'Se han agotado tus puntos. Tus restaurantes han sido desactivados.');
    END IF;
    
    RETURN true;
END;
$$ LANGUAGE plpgsql;

-- 8. Función para asignar puntos
CREATE FUNCTION asignar_puntos_dueno(
    p_dueno_id UUID,
    p_puntos INTEGER,
    p_tipo_asignacion TEXT DEFAULT 'agregar',
    p_motivo TEXT DEFAULT 'Asignación de puntos',
    p_admin_id UUID DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
    sistema_puntos_id UUID;
    puntos_actuales INTEGER;
    puntos_finales INTEGER;
BEGIN
    -- Obtener o crear sistema de puntos
    SELECT id, puntos_disponibles 
    INTO sistema_puntos_id, puntos_actuales
    FROM sistema_puntos 
    WHERE dueno_id = p_dueno_id;
    
    IF sistema_puntos_id IS NULL THEN
        INSERT INTO sistema_puntos (dueno_id, puntos_disponibles, total_asignado)
        VALUES (p_dueno_id, 0, 0)
        RETURNING id INTO sistema_puntos_id;
        puntos_actuales := 0;
    END IF;
    
    -- Calcular puntos finales
    IF p_tipo_asignacion = 'agregar' THEN
        puntos_finales := puntos_actuales + p_puntos;
    ELSIF p_tipo_asignacion = 'quitar' THEN
        puntos_finales := GREATEST(0, puntos_actuales - p_puntos);
    ELSE
        puntos_finales := p_puntos; -- Ajuste directo
    END IF;
    
    -- Actualizar puntos
    UPDATE sistema_puntos 
    SET 
        puntos_disponibles = puntos_finales,
        total_asignado = total_asignado + p_puntos,
        fecha_ultima_asignacion = NOW()
    WHERE id = sistema_puntos_id;
    
    -- Registrar asignación
    INSERT INTO asignaciones_puntos (sistema_puntos_id, puntos_asignados, tipo_asignacion, motivo, admin_id)
    VALUES (sistema_puntos_id, p_puntos, p_tipo_asignacion, p_motivo, p_admin_id);
    
    -- Crear notificación para el dueño
    INSERT INTO notificaciones_sistema (usuario_id, tipo, titulo, mensaje)
    VALUES (p_dueno_id, 'asignacion_puntos', 'Puntos Asignados', 
            'Se han ' || p_tipo_asignacion || ' ' || p_puntos || ' puntos a tu cuenta. Motivo: ' || p_motivo);
    
    RETURN true;
END;
$$ LANGUAGE plpgsql;

-- 9. Función para verificar estado de restaurantes
CREATE FUNCTION verificar_estado_restaurantes_por_puntos()
RETURNS void AS $$
BEGIN
    -- Desactivar restaurantes de dueños sin puntos
    UPDATE negocios 
    SET destacado = false
    WHERE usuarioid IN (
        SELECT dueno_id 
        FROM sistema_puntos 
        WHERE puntos_disponibles <= 0
    );
    
    -- Activar restaurantes de dueños con puntos
    UPDATE negocios 
    SET destacado = true
    WHERE usuarioid IN (
        SELECT dueno_id 
        FROM sistema_puntos 
        WHERE puntos_disponibles > 0
    );
END;
$$ LANGUAGE plpgsql;

-- 10. Función para obtener estadísticas de puntos
CREATE FUNCTION obtener_estadisticas_puntos()
RETURNS TABLE (
    total_duenos BIGINT,
    duenos_con_puntos BIGINT,
    duenos_sin_puntos BIGINT,
    total_puntos_asignados BIGINT,
    total_puntos_consumidos BIGINT,
    total_puntos_disponibles BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*) as total_duenos,
        COUNT(*) FILTER (WHERE puntos_disponibles > 0) as duenos_con_puntos,
        COUNT(*) FILTER (WHERE puntos_disponibles <= 0) as duenos_sin_puntos,
        COALESCE(SUM(total_asignado), 0) as total_puntos_asignados,
        COALESCE(SUM(total_asignado - puntos_disponibles), 0) as total_puntos_consumidos,
        COALESCE(SUM(puntos_disponibles), 0) as total_puntos_disponibles
    FROM sistema_puntos sp
    JOIN usuarios u ON sp.dueno_id = u.id
    WHERE u.rol = 'duenio';
END;
$$ LANGUAGE plpgsql;

-- 11. Vista para dashboard de puntos
CREATE VIEW dashboard_puntos AS
SELECT 
    sp.id,
    sp.dueno_id,
    u.name as dueno_nombre,
    u.email as dueno_email,
    sp.puntos_disponibles,
    sp.total_asignado,
    (sp.total_asignado - sp.puntos_disponibles) as puntos_consumidos,
    sp.puntos_por_pedido,
    sp.activo,
    sp.fecha_ultima_asignacion,
    sp.fecha_ultimo_consumo,
    CASE 
        WHEN sp.puntos_disponibles <= 0 THEN 'Sin puntos'
        WHEN sp.puntos_disponibles <= 50 THEN 'Puntos bajos'
        ELSE 'Con puntos'
    END as estado_puntos
FROM sistema_puntos sp
JOIN usuarios u ON sp.dueno_id = u.id
WHERE u.rol = 'duenio';

-- 12. Habilitar RLS
ALTER TABLE sistema_puntos ENABLE ROW LEVEL SECURITY;
ALTER TABLE asignaciones_puntos ENABLE ROW LEVEL SECURITY;
ALTER TABLE notificaciones_sistema ENABLE ROW LEVEL SECURITY;

-- 13. Políticas RLS para sistema_puntos
CREATE POLICY "Admins can manage all points" ON sistema_puntos
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM usuarios 
            WHERE id = auth.uid() AND rol = 'admin'
        )
    );

CREATE POLICY "Owners can view their own points" ON sistema_puntos
    FOR SELECT USING (dueno_id = auth.uid());

-- 14. Políticas RLS para asignaciones_puntos
CREATE POLICY "Admins can manage all assignments" ON asignaciones_puntos
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM usuarios 
            WHERE id = auth.uid() AND rol = 'admin'
        )
    );

CREATE POLICY "Owners can view their own assignments" ON asignaciones_puntos
    FOR SELECT USING (
        sistema_puntos_id IN (
            SELECT id FROM sistema_puntos WHERE dueno_id = auth.uid()
        )
    );

-- 15. Políticas RLS para notificaciones_sistema
CREATE POLICY "Users can view their own notifications" ON notificaciones_sistema
    FOR SELECT USING (usuario_id = auth.uid());

CREATE POLICY "Admins can manage all notifications" ON notificaciones_sistema
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM usuarios 
            WHERE id = auth.uid() AND rol = 'admin'
        )
    );

-- =====================================================
-- COMENTARIOS FINALES
-- =====================================================

/*
ESTRUCTURA CREADA:

1. sistema_puntos: Tabla principal con puntos disponibles y total asignado
2. asignaciones_puntos: Historial de asignaciones/quitas de puntos
3. notificaciones_sistema: Sistema de notificaciones push y en app
4. Funciones principales:
   - consumir_puntos_pedido(): Descuenta puntos al hacer pedido
   - asignar_puntos_dueno(): Asigna/quita puntos desde admin
   - verificar_estado_restaurantes_por_puntos(): Activa/desactiva restaurantes
   - obtener_estadisticas_puntos(): Estadísticas generales
5. Vistas útiles:
   - dashboard_puntos: Vista completa para dashboard

USO:
- Al crear pedido: SELECT consumir_puntos_pedido('dueno_id', 2);
- Para asignar puntos: SELECT asignar_puntos_dueno('dueno_id', 500, 'agregar', 'Recarga', 'admin_id');
- Para verificar estado: SELECT verificar_estado_restaurantes_por_puntos();
- Para estadísticas: SELECT * FROM obtener_estadisticas_puntos();
*/ 