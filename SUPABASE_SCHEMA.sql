-- =====================================================
-- ESQUEMA DE BASE DE DATOS SUPABASE
-- Migración desde Firestore a PostgreSQL
-- =====================================================

-- Habilitar extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================
-- TABLA: usuarios (equivalente a 'usuarios' en Firestore)
-- =====================================================
CREATE TABLE users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('cliente', 'duenio', 'repartidor', 'admin')),
    phone TEXT,
    address TEXT,
    profile_image TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABLA: negocios (equivalente a 'negocios' en Firestore)
-- =====================================================
CREATE TABLE businesses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    address TEXT,
    phone TEXT,
    email TEXT,
    image_url TEXT,
    logo_url TEXT,
    is_active BOOLEAN DEFAULT true,
    owner_id UUID REFERENCES users(id) ON DELETE CASCADE,
    location JSONB, -- Coordenadas GPS {lat, lng}
    category TEXT,
    rating DECIMAL(3,2) DEFAULT 0.0,
    review_count INTEGER DEFAULT 0,
    opening_hours TEXT, -- Horarios de apertura
    delivery_radius TEXT, -- Radio de entrega en km
    minimum_order DECIMAL(10,2) DEFAULT 0.0,
    delivery_fee DECIMAL(10,2) DEFAULT 0.0,
    estimated_delivery_time INTEGER, -- Tiempo estimado en minutos
    settings JSONB, -- Configuraciones del negocio
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABLA: productos (equivalente a 'productos' en Firestore)
-- =====================================================
CREATE TABLE dishes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    category TEXT NOT NULL,
    image_url TEXT,
    is_available BOOLEAN DEFAULT true,
    business_id UUID REFERENCES businesses(id) ON DELETE CASCADE,
    extras JSONB, -- Ingredientes extra, opciones, etc.
    preparation_time INTEGER, -- Tiempo de preparación en minutos
    is_featured BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABLA: categorias (equivalente a 'categorias' en Firestore)
-- =====================================================
CREATE TABLE categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    business_id UUID REFERENCES businesses(id) ON DELETE CASCADE,
    is_active BOOLEAN DEFAULT true,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABLA: pedidos (equivalente a 'pedidos' en Firestore)
-- =====================================================
CREATE TABLE orders (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    business_id UUID REFERENCES businesses(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'Pendiente' CHECK (status IN ('Pendiente', 'En preparación', 'Listo', 'En entrega', 'Entregado', 'Cancelado')),
    subtotal DECIMAL(10,2) NOT NULL,
    tax DECIMAL(10,2) NOT NULL DEFAULT 0.0,
    delivery_fee DECIMAL(10,2) NOT NULL DEFAULT 0.0,
    total DECIMAL(10,2) NOT NULL,
    items JSONB NOT NULL, -- Array de items del pedido
    address TEXT,
    phone TEXT,
    notes TEXT,
    delivery_instructions TEXT,
    estimated_delivery_time TIMESTAMP WITH TIME ZONE,
    actual_delivery_time TIMESTAMP WITH TIME ZONE,
    delivery_user_id UUID REFERENCES users(id), -- ID del repartidor
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABLA: notificaciones (nueva funcionalidad)
-- =====================================================
CREATE TABLE notifications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('order', 'system', 'promotion')),
    is_read BOOLEAN DEFAULT false,
    data JSONB, -- Datos adicionales de la notificación
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- TABLA: reseñas (nueva funcionalidad)
-- =====================================================
CREATE TABLE reviews (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    business_id UUID REFERENCES businesses(id) ON DELETE CASCADE,
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    is_public BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- ÍNDICES PARA OPTIMIZAR CONSULTAS
-- =====================================================

-- Índices para users
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_active ON users(is_active);

-- Índices para businesses
CREATE INDEX idx_businesses_owner ON businesses(owner_id);
CREATE INDEX idx_businesses_active ON businesses(is_active);
CREATE INDEX idx_businesses_category ON businesses(category);
CREATE INDEX idx_businesses_location ON businesses USING GIN(location);

-- Índices para dishes
CREATE INDEX idx_dishes_business ON dishes(business_id);
CREATE INDEX idx_dishes_category ON dishes(category);
CREATE INDEX idx_dishes_available ON dishes(is_available);
CREATE INDEX idx_dishes_featured ON dishes(is_featured);

-- Índices para orders
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_business ON orders(business_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_delivery_user ON orders(delivery_user_id);
CREATE INDEX idx_orders_created_at ON orders(created_at);

-- Índices para notifications
CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);

-- Índices para reviews
CREATE INDEX idx_reviews_business ON reviews(business_id);
CREATE INDEX idx_reviews_user ON reviews(user_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);

-- =====================================================
-- TRIGGERS PARA ACTUALIZAR updated_at
-- =====================================================

-- Función para actualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers para cada tabla
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_businesses_updated_at BEFORE UPDATE ON businesses FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_dishes_updated_at BEFORE UPDATE ON dishes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON categories FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_reviews_updated_at BEFORE UPDATE ON reviews FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- FUNCIONES PARA ACTUALIZAR RATING DE NEGOCIOS
-- =====================================================

-- Función para actualizar rating de negocio
CREATE OR REPLACE FUNCTION update_business_rating()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE businesses 
    SET 
        rating = (
            SELECT AVG(rating)::DECIMAL(3,2)
            FROM reviews 
            WHERE business_id = NEW.business_id AND is_public = true
        ),
        review_count = (
            SELECT COUNT(*)
            FROM reviews 
            WHERE business_id = NEW.business_id AND is_public = true
        )
    WHERE id = NEW.business_id;
    
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger para actualizar rating cuando se agrega/actualiza una reseña
CREATE TRIGGER update_business_rating_trigger 
    AFTER INSERT OR UPDATE OR DELETE ON reviews 
    FOR EACH ROW EXECUTE FUNCTION update_business_rating();

-- =====================================================
-- POLÍTICAS DE SEGURIDAD RLS (Row Level Security)
-- =====================================================

-- Habilitar RLS en todas las tablas
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE businesses ENABLE ROW LEVEL SECURITY;
ALTER TABLE dishes ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE reviews ENABLE ROW LEVEL SECURITY;

-- Políticas para users
CREATE POLICY "Users can view their own profile" ON users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Admins can view all users" ON users
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Políticas para businesses
CREATE POLICY "Anyone can view active businesses" ON businesses
    FOR SELECT USING (is_active = true);

CREATE POLICY "Business owners can manage their businesses" ON businesses
    FOR ALL USING (owner_id = auth.uid());

CREATE POLICY "Admins can manage all businesses" ON businesses
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM users 
            WHERE id = auth.uid() AND role = 'admin'
        )
    );

-- Políticas para dishes
CREATE POLICY "Anyone can view available dishes" ON dishes
    FOR SELECT USING (is_available = true);

CREATE POLICY "Business owners can manage their dishes" ON dishes
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM businesses 
            WHERE id = business_id AND owner_id = auth.uid()
        )
    );

-- Políticas para orders
CREATE POLICY "Users can view their own orders" ON orders
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can create their own orders" ON orders
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Business owners can view orders for their businesses" ON orders
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM businesses 
            WHERE id = business_id AND owner_id = auth.uid()
        )
    );

CREATE POLICY "Delivery users can view assigned orders" ON orders
    FOR SELECT USING (
        delivery_user_id = auth.uid() OR
        EXISTS (
            SELECT 1 FROM users 
            WHERE id = auth.uid() AND role = 'repartidor'
        )
    );

-- Políticas para notifications
CREATE POLICY "Users can view their own notifications" ON notifications
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can update their own notifications" ON notifications
    FOR UPDATE USING (user_id = auth.uid());

-- Políticas para reviews
CREATE POLICY "Anyone can view public reviews" ON reviews
    FOR SELECT USING (is_public = true);

CREATE POLICY "Users can create reviews for their orders" ON reviews
    FOR INSERT WITH CHECK (user_id = auth.uid());

-- =====================================================
-- DATOS DE PRUEBA
-- =====================================================

-- Insertar usuarios demo
INSERT INTO users (id, email, name, role, phone, address) VALUES
('550e8400-e29b-41d4-a716-446655440001', 'cliente@demo.com', 'Juan Cliente', 'cliente', '555-0123', 'Calle Principal 123'),
('550e8400-e29b-41d4-a716-446655440002', 'duenio@demo.com', 'María Dueña', 'duenio', '555-0456', 'Avenida Central 456'),
('550e8400-e29b-41d4-a716-446655440003', 'repartidor@demo.com', 'Carlos Repartidor', 'repartidor', '555-0789', 'Plaza Mayor 789'),
('550e8400-e29b-41d4-a716-446655440004', 'admin@demo.com', 'Admin Sistema', 'admin', '555-0000', 'Oficina Central');

-- Insertar negocio demo
INSERT INTO businesses (id, name, description, address, phone, email, owner_id, category, rating, review_count, minimum_order, delivery_fee, estimated_delivery_time) VALUES
('550e8400-e29b-41d4-a716-446655440010', 'Restaurante Demo', 'El mejor restaurante de la ciudad', 'Calle Comercial 100', '555-1234', 'info@restaurantedemo.com', '550e8400-e29b-41d4-a716-446655440002', 'Restaurante', 4.5, 25, 10.00, 2.50, 30);

-- Insertar platos demo
INSERT INTO dishes (id, name, description, price, category, business_id, is_available, is_featured) VALUES
('550e8400-e29b-41d4-a716-446655440020', 'Hamburguesa Clásica', 'Hamburguesa con carne, lechuga, tomate y queso', 12.99, 'Platos principales', '550e8400-e29b-41d4-a716-446655440010', true, true),
('550e8400-e29b-41d4-a716-446655440021', 'Pizza Margherita', 'Pizza con salsa de tomate, mozzarella y albahaca', 15.99, 'Platos principales', '550e8400-e29b-41d4-a716-446655440010', true, true),
('550e8400-e29b-41d4-a716-446655440022', 'Ensalada César', 'Lechuga, crutones, parmesano y aderezo César', 8.99, 'Entradas', '550e8400-e29b-41d4-a716-446655440010', true, false),
('550e8400-e29b-41d4-a716-446655440023', 'Tiramisú', 'Postre italiano con café y mascarpone', 6.99, 'Postres', '550e8400-e29b-41d4-a716-446655440010', true, false),
('550e8400-e29b-41d4-a716-446655440024', 'Coca Cola', 'Refresco de cola 350ml', 2.50, 'Bebidas', '550e8400-e29b-41d4-a716-446655440010', true, false);

-- =====================================================
-- COMENTARIOS FINALES
-- =====================================================

/*
ESTRUCTURA MIGRADA DESDE FIRESTORE:

Firestore Collection -> Supabase Table
- usuarios -> users
- negocios -> businesses  
- productos -> dishes
- categorias -> categories
- pedidos -> orders

NUEVAS TABLAS AGREGADAS:
- notifications (notificaciones push)
- reviews (reseñas de clientes)

CARACTERÍSTICAS IMPLEMENTADAS:
✅ Tipado fuerte con PostgreSQL
✅ Relaciones con claves foráneas
✅ Índices para optimización
✅ Triggers para auditoría
✅ Políticas de seguridad RLS
✅ Datos demo para testing
✅ Funciones para cálculos automáticos

PRÓXIMOS PASOS:
1. Ejecutar este script en Supabase
2. Configurar las variables de entorno
3. Probar las funcionalidades
4. Implementar notificaciones push
5. Agregar más datos demo
*/ 