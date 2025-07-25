-- =====================================================
-- CREAR DUEÑOS DE PRUEBA
-- =====================================================

-- 1. Insertar dueños de prueba (si no existen)
INSERT INTO usuarios (id, name, email, rol, telephone, address, created_at)
VALUES 
    (gen_random_uuid(), 'Juan Pérez', 'juan.perez@test.com', 'duenio', '555-0101', 'Calle Principal 123', NOW()),
    (gen_random_uuid(), 'María García', 'maria.garcia@test.com', 'duenio', '555-0102', 'Avenida Central 456', NOW()),
    (gen_random_uuid(), 'Carlos López', 'carlos.lopez@test.com', 'duenio', '555-0103', 'Plaza Mayor 789', NOW()),
    (gen_random_uuid(), 'Ana Martínez', 'ana.martinez@test.com', 'duenio', '555-0104', 'Calle Secundaria 321', NOW()),
    (gen_random_uuid(), 'Luis Rodríguez', 'luis.rodriguez@test.com', 'duenio', '555-0105', 'Boulevard Norte 654', NOW())
ON CONFLICT (email) DO NOTHING;

-- 2. Obtener los IDs de los dueños insertados
WITH duenos_ids AS (
    SELECT id FROM usuarios 
    WHERE email IN (
        'juan.perez@test.com',
        'maria.garcia@test.com', 
        'carlos.lopez@test.com',
        'ana.martinez@test.com',
        'luis.rodriguez@test.com'
    ) AND rol = 'duenio'
)
-- 3. Insertar puntos iniciales para cada dueño
INSERT INTO sistema_puntos (dueno_id, puntos_disponibles, total_asignado, puntos_por_pedido)
SELECT 
    id,
    CASE 
        WHEN email = 'juan.perez@test.com' THEN 500
        WHEN email = 'maria.garcia@test.com' THEN 300
        WHEN email = 'carlos.lopez@test.com' THEN 100
        WHEN email = 'ana.martinez@test.com' THEN 50
        WHEN email = 'luis.rodriguez@test.com' THEN 0
    END,
    CASE 
        WHEN email = 'juan.perez@test.com' THEN 500
        WHEN email = 'maria.garcia@test.com' THEN 300
        WHEN email = 'carlos.lopez@test.com' THEN 100
        WHEN email = 'ana.martinez@test.com' THEN 50
        WHEN email = 'luis.rodriguez@test.com' THEN 0
    END,
    2
FROM usuarios 
WHERE email IN (
    'juan.perez@test.com',
    'maria.garcia@test.com', 
    'carlos.lopez@test.com',
    'ana.martinez@test.com',
    'luis.rodriguez@test.com'
) AND rol = 'duenio'
ON CONFLICT (dueno_id) DO NOTHING;

-- 4. Verificar que se crearon correctamente
SELECT 
    u.name,
    u.email,
    sp.puntos_disponibles,
    sp.total_asignado,
    CASE 
        WHEN sp.puntos_disponibles <= 0 THEN 'Sin puntos'
        WHEN sp.puntos_disponibles <= 50 THEN 'Puntos bajos'
        ELSE 'Con puntos'
    END as estado
FROM usuarios u
LEFT JOIN sistema_puntos sp ON u.id = sp.dueno_id
WHERE u.rol = 'duenio'
ORDER BY sp.puntos_disponibles DESC; 