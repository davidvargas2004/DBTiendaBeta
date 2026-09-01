-- Crear base de datos
CREATE DATABASE IF NOT EXISTS tiendabeta
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE tiendabeta;

-- Tabla: Clientes
CREATE TABLE IF NOT EXISTS clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    estado VARCHAR(20) DEFAULT 'activo',
    INDEX idx_email (email),
    INDEX idx_nombre (nombre, apellido),
    CONSTRAINT chk_estado_cliente CHECK (estado IN ('activo', 'inactivo'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: Direcciones
CREATE TABLE IF NOT EXISTS direcciones (
    id_direccion INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    tipo_direccion VARCHAR(20) DEFAULT 'casa',
    calle VARCHAR(200) NOT NULL,
    numero VARCHAR(20),
    ciudad VARCHAR(100) NOT NULL,
    estado VARCHAR(100),
    codigo_postal VARCHAR(20),
    pais VARCHAR(100) DEFAULT 'Colombia',
    es_principal BOOLEAN DEFAULT FALSE,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente) ON DELETE CASCADE,
    INDEX idx_cliente (id_cliente),
    INDEX idx_ciudad (ciudad),
    CONSTRAINT chk_tipo_direccion CHECK (tipo_direccion IN ('casa', 'trabajo', 'otra'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: Pedido
CREATE TABLE IF NOT EXISTS pedido (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT NOT NULL,
    id_direccion_envio INT,
    fecha_pedido DATETIME DEFAULT CURRENT_TIMESTAMP,
    estado_pedido VARCHAR(30) DEFAULT 'pendiente',
    total DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    metodo_pago VARCHAR(50),
    notas TEXT,
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente) ON DELETE RESTRICT,
    FOREIGN KEY (id_direccion_envio) REFERENCES direcciones(id_direccion) ON DELETE SET NULL,
    INDEX idx_cliente (id_cliente),
    INDEX idx_fecha (fecha_pedido),
    INDEX idx_estado (estado_pedido),
    CONSTRAINT chk_estado_pedido CHECK (estado_pedido IN ('pendiente', 'procesando', 'enviado', 'entregado', 'cancelado'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabla: DetalleDePedidos
CREATE TABLE IF NOT EXISTS detalledepedidos (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT NOT NULL,
    producto_nombre VARCHAR(200) NOT NULL,
    cantidad INT NOT NULL DEFAULT 1,
    precio_unitario DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (id_pedido) REFERENCES pedido(id_pedido) ON DELETE CASCADE,
    INDEX idx_pedido (id_pedido)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Trigger para actualizar el total del pedido
DROP TRIGGER IF EXISTS actualizar_total_pedido;

DELIMITER $$

CREATE TRIGGER actualizar_total_pedido
AFTER INSERT ON detalledepedidos
FOR EACH ROW
BEGIN
    UPDATE pedido 
    SET total = (
        SELECT COALESCE(SUM(subtotal), 0)
        FROM detalledepedidos
        WHERE id_pedido = NEW.id_pedido
    )
    WHERE id_pedido = NEW.id_pedido;
END$$

DELIMITER ;