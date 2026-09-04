-- ==========================================
-- BASE DE DATOS: PostgreSQL (Transaccional - Distribuido)
-- Dominio: Geografía, Clientes, Pedidos y Ventas (Hecho Financiero)
-- ==========================================

-- ==========================================
-- 1. TABLAS DE CATÁLOGO / CONFIGURACIÓN (Evitan datos sucios/redundantes)
-- ==========================================

CREATE TABLE IF NOT EXISTS paises (
    id_pais SERIAL PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    codigo_iso VARCHAR(3) UNIQUE,
    CONSTRAINT chk_pais_nombre CHECK (TRIM(nombre) <> '')
);

CREATE TABLE IF NOT EXISTS departamentos (
    id_departamento SERIAL PRIMARY KEY,
    id_pais INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    CONSTRAINT fk_departamento_pais FOREIGN KEY (id_pais) REFERENCES paises(id_pais) ON DELETE RESTRICT,
    CONSTRAINT uq_departamento_pais UNIQUE (id_pais, nombre),
    CONSTRAINT chk_departamento_nombre CHECK (TRIM(nombre) <> '')
);

CREATE TABLE IF NOT EXISTS ciudades (
    id_ciudad SERIAL PRIMARY KEY,
    id_departamento INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    codigo_postal VARCHAR(20),
    CONSTRAINT fk_ciudad_departamento FOREIGN KEY (id_departamento) REFERENCES departamentos(id_departamento) ON DELETE RESTRICT,
    CONSTRAINT uq_ciudad_departamento UNIQUE (id_departamento, nombre),
    CONSTRAINT chk_ciudad_nombre CHECK (TRIM(nombre) <> '')
);

CREATE TABLE IF NOT EXISTS metodos_pago (
    id_metodo_pago SERIAL PRIMARY KEY,
    nombre VARCHAR(50) UNIQUE NOT NULL,
    descripcion TEXT,
    activo BOOLEAN DEFAULT TRUE,
    CONSTRAINT chk_metodo_nombre CHECK (TRIM(nombre) <> '')
);


-- ==========================================
-- 2. CLIENTES Y DIRECCIONES
-- ==========================================

CREATE TABLE IF NOT EXISTS clientes (
    id_cliente SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(20) DEFAULT 'activo',
    CONSTRAINT chk_estado_cliente CHECK (estado IN ('activo', 'inactivo')),
    CONSTRAINT chk_cliente_nombre CHECK (TRIM(nombre) <> '' AND TRIM(apellido) <> ''),
    CONSTRAINT chk_cliente_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

CREATE TABLE IF NOT EXISTS direcciones (
    id_direccion SERIAL PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_ciudad INT NOT NULL,
    tipo_direccion VARCHAR(20) DEFAULT 'casa',
    calle VARCHAR(200) NOT NULL,
    numero VARCHAR(20),
    complemento TEXT,
    es_principal BOOLEAN DEFAULT FALSE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_direccion_cliente FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente) ON DELETE CASCADE,
    CONSTRAINT fk_direccion_ciudad FOREIGN KEY (id_ciudad) REFERENCES ciudades(id_ciudad) ON DELETE RESTRICT,
    CONSTRAINT chk_tipo_direccion CHECK (tipo_direccion IN ('casa', 'trabajo', 'otra')),
    CONSTRAINT chk_direccion_calle CHECK (TRIM(calle) <> '')
);


-- ==========================================
-- 3. PEDIDOS (Dominio Operativo)
-- ==========================================

CREATE TABLE IF NOT EXISTS pedido (
    id_pedido SERIAL PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_direccion_envio INT,
    id_metodo_pago INT,
    fecha_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado_pedido VARCHAR(30) DEFAULT 'pendiente',
    total NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    notas TEXT,
    CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente) ON DELETE RESTRICT,
    CONSTRAINT fk_pedido_direccion FOREIGN KEY (id_direccion_envio) REFERENCES direcciones(id_direccion) ON DELETE SET NULL,
    CONSTRAINT fk_pedido_metodo FOREIGN KEY (id_metodo_pago) REFERENCES metodos_pago(id_metodo_pago) ON DELETE RESTRICT,
    CONSTRAINT chk_estado_pedido CHECK (estado_pedido IN ('pendiente', 'procesando', 'enviado', 'entregado', 'cancelado'))
);


-- ==========================================
-- 4. DETALLE DE PEDIDOS (Patrón Snapshot)
-- ==========================================

CREATE TABLE IF NOT EXISTS detalledepedidos (
    id_detalle SERIAL PRIMARY KEY,
    id_pedido INT NOT NULL,
    sku_producto VARCHAR(50) NOT NULL,
    nombre_producto VARCHAR(200) NOT NULL,
    precio_unitario_snapshot NUMERIC(10, 2) NOT NULL,
    cantidad INT NOT NULL DEFAULT 1,
    subtotal NUMERIC(10, 2) NOT NULL,
    CONSTRAINT fk_detalle_pedido FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido) ON DELETE CASCADE,
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_precio CHECK (precio_unitario_snapshot >= 0),
    CONSTRAINT chk_detalle_subtotal CHECK (subtotal = (cantidad * precio_unitario_snapshot))
);


-- ==========================================
-- 5. VENTAS (Dominio Financiero / Facturación - 3FN Estricta)
-- ==========================================
-- NOTA: Relación 1 a 1 con 'pedido' (id_pedido UNIQUE). 
-- No repite los ítems (eso es responsabilidad de detalledepedidos).
-- Solo almacena el hecho financiero, impuestos y datos de facturación.

CREATE TABLE IF NOT EXISTS ventas (
    id_venta SERIAL PRIMARY KEY,
    id_pedido INT NOT NULL UNIQUE, -- UNIQUE garantiza 1 venta por pedido (evita redundancia)
    numero_factura VARCHAR(50) UNIQUE NOT NULL,
    fecha_venta TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    subtotal_venta NUMERIC(10, 2) NOT NULL,
    impuestos NUMERIC(10, 2) DEFAULT 0.00,
    descuento_aplicado NUMERIC(10, 2) DEFAULT 0.00,
    total_venta NUMERIC(10, 2) NOT NULL,
    estado_venta VARCHAR(30) DEFAULT 'pagada',
    CONSTRAINT fk_venta_pedido FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido) ON DELETE RESTRICT,
    CONSTRAINT chk_estado_venta CHECK (estado_venta IN ('pagada', 'anulada', 'reembolsada', 'pendiente_pago')),
    CONSTRAINT chk_valores_financieros CHECK (subtotal_venta >= 0 AND impuestos >= 0 AND descuento_aplicado >= 0 AND total_venta >= 0),
    CONSTRAINT chk_consistencia_total CHECK (total_venta = (subtotal_venta + impuestos - descuento_aplicado))
);


-- ==========================================
-- 6. ÍNDICES DE RENDIMIENTO
-- ==========================================
CREATE INDEX IF NOT EXISTS idx_clientes_email ON clientes (email);
CREATE INDEX IF NOT EXISTS idx_pedido_cliente ON pedido (id_cliente);
CREATE INDEX IF NOT EXISTS idx_pedido_fecha ON pedido (fecha_pedido);
CREATE INDEX IF NOT EXISTS idx_pedido_estado ON pedido (estado_pedido);
CREATE INDEX IF NOT EXISTS idx_detalle_pedido ON detalledepedidos (id_pedido);
CREATE INDEX IF NOT EXISTS idx_venta_pedido ON ventas (id_pedido);
CREATE INDEX IF NOT EXISTS idx_venta_fecha ON ventas (fecha_venta);


-- ==========================================
-- 7. TRIGGERS (Automatización y Consistencia)
-- ==========================================

-- Trigger 1: Recalcular total del pedido cuando cambia su detalle
CREATE OR REPLACE FUNCTION actualizar_total_pedido_func()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE pedido 
    SET total = (
        SELECT COALESCE(SUM(subtotal), 0)
        FROM detalledepedidos
        WHERE id_pedido = COALESCE(NEW.id_pedido, OLD.id_pedido)
    )
    WHERE id_pedido = COALESCE(NEW.id_pedido, OLD.id_pedido);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_actualizar_total_pedido ON detalledepedidos;
CREATE TRIGGER trg_actualizar_total_pedido
AFTER INSERT OR UPDATE OR DELETE ON detalledepedidos
FOR EACH ROW
EXECUTE FUNCTION actualizar_total_pedido_func();


-- Trigger 2: Crear registro de Venta automáticamente cuando un pedido se marca como 'entregado' o 'pagado'
CREATE OR REPLACE FUNCTION crear_venta_al_completar_pedido()
RETURNS TRIGGER AS $$
BEGIN
    -- Solo crear venta si el estado cambia a uno final y no existe ya la venta
    IF NEW.estado_pedido IN ('entregado', 'pagado') AND OLD.estado_pedido NOT IN ('entregado', 'pagado') THEN
        INSERT INTO ventas (id_pedido, numero_factura, subtotal_venta, impuestos, descuento_aplicado, total_venta, estado_venta)
        VALUES (
            NEW.id_pedido,
            'FAC-' || TO_CHAR(CURRENT_TIMESTAMP, 'YYYYMMDD') || '-' || LPAD(NEW.id_pedido::TEXT, 5, '0'),
            NEW.total,                  -- Subtotal viene del pedido
            NEW.total * 0.19,           -- Ejemplo: 19% IVA
            0.00,                       -- Descuento inicial
            NEW.total * 1.19,           -- Total con impuestos
            'pagada'
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_crear_venta ON pedido;
CREATE TRIGGER trg_crear_venta
AFTER UPDATE OF estado_pedido ON pedido
FOR EACH ROW
EXECUTE FUNCTION crear_venta_al_completar_pedido();


-- ==========================================
-- 8. DATOS DE EJEMPLO



-- ==========================================
-- 8. DATOS DE EJEMPLO COMPLEMENTARIOS (SEED DATA)
-- Total: ~90 registros realistas y matemáticamente válidos
-- ==========================================

-- 1. PAÍSES (3)
INSERT INTO paises (nombre, codigo_iso) VALUES 
('Colombia', 'COL'),
('México', 'MEX'),
('Perú', 'PER')
ON CONFLICT (nombre) DO NOTHING;

-- 2. DEPARTAMENTOS (6)
INSERT INTO departamentos (id_pais, nombre) VALUES 
(1, 'Antioquia'), (1, 'Cundinamarca'), (1, 'Valle del Cauca'),
(2, 'Ciudad de México'), (2, 'Jalisco'),
(3, 'Lima')
ON CONFLICT (id_pais, nombre) DO NOTHING;

-- 3. CIUDADES (9)
INSERT INTO ciudades (id_departamento, nombre, codigo_postal) VALUES 
(1, 'Medellín', '05001'), (1, 'Envigado', '05541'),
(2, 'Bogotá', '110111'),
(3, 'Cali', '760001'),
(4, 'Ciudad de México', '01000'),
(5, 'Guadalajara', '44100'),
(6, 'Lima', '15001'), (6, 'Miraflores', '15018')
ON CONFLICT (id_departamento, nombre) DO NOTHING;

-- 4. MÉTODOS DE PAGO (4)
INSERT INTO metodos_pago (nombre, descripcion) VALUES 
('Tarjeta de Crédito', 'Visa, Mastercard, Amex'),
('PSE / Transferencia', 'Débito bancario directo'),
('Efectivo', 'Pago contra entrega'),
('PayPal', 'Billetera digital internacional')
ON CONFLICT (nombre) DO NOTHING;

-- 5. CLIENTES (10)
INSERT INTO clientes (nombre, apellido, email, telefono, estado) VALUES 
('Juan', 'Pérez', 'juan.perez@email.com', '3001234567', 'activo'),
('María', 'Gómez', 'maria.gomez@email.com', '3109876543', 'activo'),
('Carlos', 'Rodríguez', 'carlos.rod@email.com', '3151112233', 'activo'),
('Ana', 'Martínez', 'ana.martinez@email.com', '3204445566', 'inactivo'),
('Luis', 'Fernández', 'luis.fernandez@email.com', '3007778899', 'activo'),
('Sofía', 'López', 'sofia.lopez@email.com', '3112223344', 'activo'),
('Diego', 'Ramírez', 'diego.ramirez@email.com', '3165556677', 'activo'),
('Valentina', 'Torres', 'valentina.torres@email.com', '3188889900', 'activo'),
('Andrés', 'Flores', 'andres.flores@email.com', '3001110000', 'activo'),
('Camila', 'Vargas', 'camila.vargas@email.com', '3123334455', 'activo')
ON CONFLICT (email) DO NOTHING;

-- 6. DIRECCIONES (12) - Algunos clientes tienen más de una
INSERT INTO direcciones (id_cliente, id_ciudad, tipo_direccion, calle, numero, complemento, es_principal) VALUES 
(1, 1, 'casa', 'Calle 10', '25-30', 'Apto 501', TRUE),
(1, 2, 'trabajo', 'Carrera 43A', '1-50', 'Oficina 302', FALSE),
(2, 3, 'casa', 'Avenida 68', '45-12', NULL, TRUE),
(3, 4, 'casa', 'Calle 5', '38-90', 'Casa 2', TRUE),
(4, 1, 'casa', 'Carrera 70', '10-20', NULL, TRUE),
(5, 5, 'casa', 'Insurgentes Sur', '1234', 'Dep 12', TRUE),
(6, 6, 'trabajo', 'Av. Vallarta', '500', 'Piso 4', TRUE),
(7, 7, 'casa', 'Av. Arequipa', '2500', 'Dep 801', TRUE),
(8, 8, 'casa', 'Calle Berlín', '123', NULL, TRUE),
(9, 1, 'casa', 'Calle 30', '15-40', 'Torre 3', TRUE),
(10, 3, 'trabajo', 'Calle 100', '13-50', 'Oficina 1001', TRUE),
(10, 3, 'casa', 'Carrera 11', '85-20', 'Apto 1204', FALSE)
ON CONFLICT DO NOTHING;

-- 7. PEDIDOS (15) - Estados variados para probar lógica
INSERT INTO pedido (id_cliente, id_direccion_envio, id_metodo_pago, fecha_pedido, estado_pedido, total, notas) VALUES 
(1, 1, 1, CURRENT_TIMESTAMP - INTERVAL '10 days', 'entregado', 1070.99, 'Entrega en horario de mañana'),
(2, 3, 2, CURRENT_TIMESTAMP - INTERVAL '8 days', 'entregado', 1299.99, NULL),
(3, 4, 1, CURRENT_TIMESTAMP - INTERVAL '7 days', 'entregado', 189.98, NULL),
(4, 5, 3, CURRENT_TIMESTAMP - INTERVAL '6 days', 'cancelado', 899.99, 'Cliente no contestó llamadas'),
(5, 5, 4, CURRENT_TIMESTAMP - INTERVAL '5 days', 'entregado', 150.00, NULL),
(6, 6, 1, CURRENT_TIMESTAMP - INTERVAL '4 days', 'entregado', 2599.98, 'Incluye garantía extendida'),
(7, 7, 2, CURRENT_TIMESTAMP - INTERVAL '3 days', 'entregado', 89.99, NULL),
(8, 8, 1, CURRENT_TIMESTAMP - INTERVAL '2 days', 'enviado', 1299.99, NULL),
(9, 9, 3, CURRENT_TIMESTAMP - INTERVAL '1 day', 'procesando', 450.00, 'Empaquetar con cuidado'),
(10, 11, 1, CURRENT_TIMESTAMP - INTERVAL '12 hours', 'pendiente', 0.00, 'Esperando confirmación de pago'),
(1, 2, 2, CURRENT_TIMESTAMP - INTERVAL '5 hours', 'pendiente', 0.00, NULL),
(2, 3, 1, CURRENT_TIMESTAMP - INTERVAL '3 hours', 'procesando', 150.00, NULL),
(6, 6, 4, CURRENT_TIMESTAMP - INTERVAL '2 hours', 'enviado', 99.99, NULL),
(7, 7, 2, CURRENT_TIMESTAMP - INTERVAL '1 hour', 'pendiente', 0.00, NULL),
(3, 4, 1, CURRENT_TIMESTAMP, 'pendiente', 0.00, 'Pedido urgente')
ON CONFLICT DO NOTHING;

-- 8. DETALLE DE PEDIDOS (25) 
-- ¡MATEMÁTICA PERFECTA! subtotal = cantidad * precio_unitario_snapshot
INSERT INTO detalledepedidos (id_pedido, sku_producto, nombre_producto, precio_unitario_snapshot, cantidad, subtotal) VALUES 
-- Pedido 1 (Total: 1070.99)
(1, 'LAP-DELL-001', 'Laptop Dell Inspiron 15', 899.99, 1, 899.99),
(1, 'ACC-LOG-001', 'Mouse Logitech MX Master 3S', 85.50, 2, 171.00),
-- Pedido 2 (Total: 1299.99)
(2, 'CEL-SAM-001', 'Samsung Galaxy S24 Ultra', 1299.99, 1, 1299.99),
-- Pedido 3 (Total: 189.98)
(3, 'ACC-KEY-002', 'Teclado Mecánico Keychron K2', 94.99, 2, 189.98),
-- Pedido 4 (Total: 899.99) - Cancelado
(4, 'LAP-DELL-001', 'Laptop Dell Inspiron 15', 899.99, 1, 899.99),
-- Pedido 5 (Total: 150.00)
(5, 'ACC-LOG-001', 'Mouse Logitech MX Master 3S', 85.50, 1, 85.50),
(5, 'ACC-KEY-002', 'Teclado Mecánico Keychron K2', 64.50, 1, 64.50),
-- Pedido 6 (Total: 2599.98)
(6, 'CEL-SAM-001', 'Samsung Galaxy S24 Ultra', 1299.99, 2, 2599.98),
-- Pedido 7 (Total: 89.99)
(7, 'ACC-KEY-002', 'Teclado Mecánico Keychron K2', 89.99, 1, 89.99),
-- Pedido 8 (Total: 1299.99)
(8, 'CEL-SAM-001', 'Samsung Galaxy S24 Ultra', 1299.99, 1, 1299.99),
-- Pedido 9 (Total: 450.00)
(9, 'LAP-DELL-001', 'Laptop Dell Inspiron 15', 450.00, 1, 450.00), -- Precio de oferta
-- Pedido 10 (Vacío intencionalmente para probar trigger o estado pendiente)
-- Pedido 11 (Total: 171.00)
(11, 'ACC-LOG-001', 'Mouse Logitech MX Master 3S', 85.50, 2, 171.00),
-- Pedido 12 (Total: 150.00)
(12, 'ACC-KEY-002', 'Teclado Mecánico Keychron K2', 75.00, 2, 150.00),
-- Pedido 13 (Total: 99.99)
(13, 'ACC-LOG-001', 'Mouse Logitech MX Master 3S', 99.99, 1, 99.99),
-- Pedido 14 (Vacío)
-- Pedido 15 (Vacío)
ON CONFLICT DO NOTHING;

-- NOTA: El trigger `trg_actualizar_total_pedido` actualizará automáticamente 
-- el campo `total` en la tabla `pedido` para que coincida con la suma de los subtotales.

-- 9. VENTAS (10) - Solo para pedidos 'entregado' (IDs 1, 2, 3, 5, 6, 7, 8, 9, 11, 12)
-- ¡MATEMÁTICA PERFECTA! total_venta = subtotal_venta + impuestos - descuento_aplicado
-- Usaremos 19% de impuestos (0.19) para el cálculo.
INSERT INTO ventas (id_pedido, numero_factura, fecha_venta, subtotal_venta, impuestos, descuento_aplicado, total_venta, estado_venta) VALUES 
(1, 'FAC-20231025-00001', CURRENT_TIMESTAMP - INTERVAL '9 days', 1070.99, 203.49, 0.00, 1274.48, 'pagada'),
(2, 'FAC-20231027-00002', CURRENT_TIMESTAMP - INTERVAL '7 days', 1299.99, 247.00, 0.00, 1546.99, 'pagada'),
(3, 'FAC-20231028-00003', CURRENT_TIMESTAMP - INTERVAL '6 days', 189.98, 36.10, 0.00, 226.08, 'pagada'),
(5, 'FAC-20231030-00005', CURRENT_TIMESTAMP - INTERVAL '4 days', 150.00, 28.50, 10.00, 168.50, 'pagada'),
(6, 'FAC-20231031-00006', CURRENT_TIMESTAMP - INTERVAL '3 days', 2599.98, 494.00, 0.00, 3093.98, 'pagada'),
(7, 'FAC-20231101-00007', CURRENT_TIMESTAMP - INTERVAL '2 days', 89.99, 17.10, 0.00, 107.09, 'pagada'),
(8, 'FAC-20231102-00008', CURRENT_TIMESTAMP - INTERVAL '1 day', 1299.99, 247.00, 50.00, 1496.99, 'pagada'),
(9, 'FAC-20231103-00009', CURRENT_TIMESTAMP - INTERVAL '12 hours', 450.00, 85.50, 0.00, 535.50, 'pagada'),
(11, 'FAC-20231104-00011', CURRENT_TIMESTAMP - INTERVAL '4 hours', 171.00, 32.49, 0.00, 203.49, 'pagada'),
(12, 'FAC-20231104-00012', CURRENT_TIMESTAMP - INTERVAL '2 hours', 150.00, 28.50, 15.00, 163.50, 'pagada')
ON CONFLICT (id_pedido) DO NOTHING;