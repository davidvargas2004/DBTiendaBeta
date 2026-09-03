-- ==========================================
-- BASE DE DATOS: PostgreSQL (Transaccional - Distribuido)
-- Dominio: Clientes, Geografía y Pedidos
-- ==========================================

-- ==========================================
-- 1. GEOGRAFÍA (Normalización de direcciones)
-- ==========================================

CREATE TABLE IF NOT EXISTS paises (
    id_pais SERIAL PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    codigo_iso VARCHAR(3) UNIQUE,
    CONSTRAINT chk_pais_nombre CHECK (nombre <> '')
);

CREATE TABLE IF NOT EXISTS departamentos (
    id_departamento SERIAL PRIMARY KEY,
    id_pais INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    CONSTRAINT fk_departamento_pais FOREIGN KEY (id_pais) REFERENCES paises(id_pais) ON DELETE RESTRICT,
    CONSTRAINT uq_departamento_pais UNIQUE (id_pais, nombre),
    CONSTRAINT chk_departamento_nombre CHECK (nombre <> '')
);

CREATE TABLE IF NOT EXISTS ciudades (
    id_ciudad SERIAL PRIMARY KEY,
    id_departamento INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    codigo_postal VARCHAR(20),
    CONSTRAINT fk_ciudad_departamento FOREIGN KEY (id_departamento) REFERENCES departamentos(id_departamento) ON DELETE RESTRICT,
    CONSTRAINT uq_ciudad_departamento UNIQUE (id_departamento, nombre),
    CONSTRAINT chk_ciudad_nombre CHECK (nombre <> '')
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
    CONSTRAINT chk_cliente_nombre CHECK (nombre <> '' AND apellido <> '')
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
    CONSTRAINT chk_tipo_direccion CHECK (tipo_direccion IN ('casa', 'trabajo', 'otra'))
);


-- ==========================================
-- 3. PEDIDOS (Dominio Transaccional)
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


-- ==========================================
-- 4. DETALLE DE PEDIDOS (Patrón Snapshot para DB Distribuida)
-- ==========================================
-- NOTA: No hay Foreign Key a 'productos' porque esa tabla vive en MySQL.
-- Guardamos el 'snapshot' (foto) del producto al momento de la compra 
-- para garantizar la integridad histórica de los datos.

CREATE TABLE IF NOT EXISTS detalledepedidos (
    id_detalle SERIAL PRIMARY KEY,
    id_pedido INT NOT NULL,
    
    -- Snapshot del producto (Datos traídos desde MySQL en el momento de la compra)
    sku_producto VARCHAR(50) NOT NULL,
    nombre_producto VARCHAR(200) NOT NULL,
    precio_unitario_snapshot NUMERIC(10, 2) NOT NULL,
    
    cantidad INT NOT NULL DEFAULT 1,
    subtotal NUMERIC(10, 2) NOT NULL,
    
    CONSTRAINT fk_detalle_pedido FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido) ON DELETE CASCADE,
    CONSTRAINT chk_detalle_cantidad CHECK (cantidad > 0),
    CONSTRAINT chk_detalle_precio CHECK (precio_unitario_snapshot >= 0)
);


-- ==========================================
-- 5. TRIGGERS (Automatización de totales)
-- ==========================================

CREATE OR REPLACE FUNCTION actualizar_total_pedido_func()
RETURNS TRIGGER AS $$
BEGIN
    -- Recalcula el total del pedido sumando los subtotales de sus detalles
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

DROP TRIGGER IF EXISTS actualizar_total_pedido ON detalledepedidos;

CREATE TRIGGER actualizar_total_pedido
AFTER INSERT OR UPDATE OR DELETE ON detalledepedidos
FOR EACH ROW
EXECUTE FUNCTION actualizar_total_pedido_func();


-- ==========================================
-- 6. DATOS DE EJEMPLO (Geografía y Cliente)
-- ==========================================

INSERT INTO paises (nombre, codigo_iso) VALUES ('Colombia', 'COL') ON CONFLICT DO NOTHING;
INSERT INTO departamentos (id_pais, nombre) VALUES (1, 'Antioquia') ON CONFLICT DO NOTHING;
INSERT INTO ciudades (id_departamento, nombre, codigo_postal) VALUES (1, 'Medellín', '05001') ON CONFLICT DO NOTHING;

INSERT INTO clientes (nombre, apellido, email, telefono) VALUES 
('Juan', 'Pérez', 'juan.perez@ejemplo.com', '3001234567') ON CONFLICT DO NOTHING;

INSERT INTO direcciones (id_cliente, id_ciudad, tipo_direccion, calle, numero) VALUES 
(1, 1, 'casa', 'Calle 10', '25-30') ON CONFLICT DO NOTHING;