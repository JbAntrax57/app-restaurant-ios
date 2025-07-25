-- =====================================================
-- DIAGNÓSTICO DEL SISTEMA DE PUNTOS
-- =====================================================

-- 1. Verificar usuarios con rol 'duenio'
SELECT 
    id,
    name,
    email,
    rol,
    created_at
FROM usuarios 
WHERE rol = 'duenio'
ORDER BY created_at DESC;

-- 2. Verificar si hay datos en sistema_puntos
SELECT 
    sp.*,
    u.name as dueno_nombre,
    u.email as dueno_email
FROM sistema_puntos sp
JOIN usuarios u ON sp.dueno_id = u.id
ORDER BY sp.created_at DESC;

-- 3. Verificar la vista dashboard_puntos
SELECT * FROM dashboard_puntos;

-- 4. Verificar si hay errores en la función obtener_estadisticas_puntos
SELECT * FROM obtener_estadisticas_puntos();

-- 5. Verificar políticas RLS
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE tablename IN ('sistema_puntos', 'asignaciones_puntos', 'notificaciones_sistema');

-- 6. Verificar si el usuario actual tiene permisos
SELECT 
    auth.uid() as current_user_id,
    auth.role() as current_user_role; 