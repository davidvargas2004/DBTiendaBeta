-- ==========================================
-- BASE DE DATOS: PostgreSQL (Transaccional)
-- Tablas: clientes, direcciones, pedido, detalledepedidos
-- ==========================================

-- ==========================================
-- 1. TABLA: Clientes
-- ==========================================
CREATE TABLE IF NOT EXISTS clientes (
    id_cliente SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(20) DEFAULT 'activo',
    CONSTRAINT chk_estado_cliente CHECK (estado IN ('activo', 'inactivo'))
);

-- Índices para clientes
CREATE INDEX IF NOT EXISTS idx_clientes_email ON clientes (email);
CREATE INDEX IF NOT EXISTS idx_clientes_nombre ON clientes (nombre, apellido);


-- ==========================================
-- 2. TABLA: Direcciones
-- ==========================================
CREATE TABLE IF NOT EXISTS direcciones (
    id_direccion SERIAL PRIMARY KEY,
    id_cliente INT NOT NULL,
    tipo_direccion VARCHAR(20) DEFAULT 'casa',
    calle VARCHAR(200) NOT NULL,
    numero VARCHAR(20),
    ciudad VARCHAR(100) NOT NULL,
    estado VARCHAR(100),
    codigo_postal VARCHAR(20),
    pais VARCHAR(100) DEFAULT 'Colombia',
    es_principal BOOLEAN DEFAULT FALSE,
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_direccion_cliente FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente) ON DELETE CASCADE,
    CONSTRAINT chk_tipo_direccion CHECK (tipo_direccion IN ('casa', 'trabajo', 'otra'))
);

-- Índices para direcciones
CREATE INDEX IF NOT EXISTS idx_direcciones_cliente ON direcciones (id_cliente);
CREATE INDEX IF NOT EXISTS idx_direcciones_ciudad ON direcciones (ciudad);


-- ==========================================
-- 3. TABLA: Pedido
-- ==========================================
CREATE TABLE IF NOT EXISTS pedido (
    id_pedido SERIAL PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_direccion_envio INT,
    fecha_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado_pedido VARCHAR(30) DEFAULT 'pendiente',
    total NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    metodo_pago VARCHAR(50),
    notas TEXT,
    CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente) ON DELETE RESTRICT,
    CONSTRAINT fk_pedido_direccion FOREIGN KEY (id_direccion_envio) REFERENCES direcciones(id_direccion) ON DELETE SET NULL,
    CONSTRAINT chk_estado_pedido CHECK (estado_pedido IN ('pendiente', 'procesando', 'enviado', 'entregado', 'cancelado'))
);

-- Índices para pedido
CREATE INDEX IF NOT EXISTS idx_pedido_cliente ON pedido (id_cliente);
CREATE INDEX IF NOT EXISTS idx_pedido_fecha ON pedido (fecha_pedido);
CREATE INDEX IF NOT EXISTS idx_pedido_estado ON pedido (estado_pedido);


-- ==========================================
-- 4. TABLA: DetalleDePedidos
-- ==========================================
CREATE TABLE IF NOT EXISTS detalledepedidos (
    id_detalle SERIAL PRIMARY KEY,
    id_pedido INT NOT NULL,
    producto_nombre VARCHAR(200) NOT NULL,
    cantidad INT NOT NULL DEFAULT 1,
    precio_unitario NUMERIC(10, 2) NOT NULL,
    subtotal NUMERIC(10, 2) NOT NULL,
    CONSTRAINT fk_detalle_pedido FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido) ON DELETE CASCADE
);

-- Índices para detalledepedidos
CREATE INDEX IF NOT EXISTS idx_detalle_pedido ON detalledepedidos (id_pedido);


-- ==========================================
-- 5. TRIGGER: Actualizar total del pedido automáticamente
-- ==========================================

-- Paso 1: Crear la función en PL/pgSQL
CREATE OR REPLACE FUNCTION actualizar_total_pedido_func()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE pedido 
    SET total = (
        SELECT COALESCE(SUM(subtotal), 0)
        FROM detalledepedidos
        WHERE id_pedido = NEW.id_pedido
    )
    WHERE id_pedido = NEW.id_pedido;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Paso 2: Asociar la función al Trigger
DROP TRIGGER IF EXISTS actualizar_total_pedido ON detalledepedidos;

CREATE TRIGGER actualizar_total_pedido
AFTER INSERT ON detalledepedidos
FOR EACH ROW
EXECUTE FUNCTION actualizar_total_pedido_func();