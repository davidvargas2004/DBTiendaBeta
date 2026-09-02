-- ==========================================
-- BASE DE DATOS: MySQL (TiendaBeta - Normalizado 3FN)
-- ==========================================

CREATE DATABASE IF NOT EXISTS tiendabeta
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE tiendabeta;

-- ==========================================
-- 1. TABLA: Marcas (Elimina dependencia transitiva de la marca)
-- ==========================================
CREATE TABLE IF NOT EXISTS marcas (
    id_marca INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    pais_origen VARCHAR(100),
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_nombre_marca (nombre)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ==========================================
-- 2. TABLA: Categorias (Elimina dependencia transitiva de categoría/subcategoría)
-- ==========================================
CREATE TABLE IF NOT EXISTS categorias (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) UNIQUE NOT NULL,
    subcategoria VARCHAR(100),
    descripcion TEXT,
    INDEX idx_nombre_categoria (nombre, subcategoria)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ==========================================
-- 3. TABLA: Productos (Entidad central, solo depende de su PK)
-- ==========================================
CREATE TABLE IF NOT EXISTS productos (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    id_marca INT NOT NULL,
    id_categoria INT NOT NULL,
    sku VARCHAR(50) UNIQUE NOT NULL COMMENT 'Código único de inventario',
    nombre VARCHAR(200) NOT NULL,
    modelo VARCHAR(100) NOT NULL,
    descripcion TEXT,
    
    -- Características físicas (Atributos directos del producto)
    color VARCHAR(50),
    talla VARCHAR(50),
    peso_gramos DECIMAL(8,2),
    dimensiones_cm VARCHAR(50),
    
    -- Precios
    precio_costo DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    precio_venta DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    precio_oferta DECIMAL(10, 2) DEFAULT 0.00,
    
    -- Inventario
    stock_actual INT NOT NULL DEFAULT 0,
    stock_minimo INT NOT NULL DEFAULT 5,
    stock_maximo INT NOT NULL DEFAULT 100,
    ubicacion_almacen VARCHAR(50),
    
    -- Estado y Fechas
    estado VARCHAR(20) DEFAULT 'activo',
    destacado BOOLEAN DEFAULT FALSE,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Llaves Foráneas (2FN y 3FN)
    CONSTRAINT fk_producto_marca FOREIGN KEY (id_marca) REFERENCES marcas(id_marca) ON DELETE RESTRICT,
    CONSTRAINT fk_producto_categoria FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria) ON DELETE RESTRICT,
    
    -- Restricciones de Integridad (Sin ENUMs)
    CONSTRAINT chk_estado_producto CHECK (estado IN ('activo', 'inactivo', 'descontinuado', 'agotado')),
    CONSTRAINT chk_stock_valido CHECK (stock_actual >= 0 AND stock_minimo <= stock_maximo),
    CONSTRAINT chk_precios_validos CHECK (precio_venta >= 0 AND precio_costo >= 0),
    
    INDEX idx_sku (sku),
    INDEX idx_marca (id_marca),
    INDEX idx_categoria (id_categoria),
    INDEX idx_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ==========================================
-- 4. TABLA: Producto_Imagenes (Cumple 1FN: Atomicidad, una imagen por fila)
-- ==========================================
CREATE TABLE IF NOT EXISTS producto_imagenes (
    id_imagen INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    url_imagen VARCHAR(500) NOT NULL,
    es_principal BOOLEAN DEFAULT FALSE,
    orden_visual INT DEFAULT 0,
    CONSTRAINT fk_imagen_producto FOREIGN KEY (id_producto) REFERENCES productos(id_producto) ON DELETE CASCADE,
    INDEX idx_producto_imagen (id_producto)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ==========================================
-- 5. TABLA: Producto_Especificaciones (Cumple 1FN y 3FN: Modelo EAV)
-- ==========================================
CREATE TABLE IF NOT EXISTS producto_especificaciones (
    id_especificacion INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT NOT NULL,
    clave VARCHAR(100) NOT NULL COMMENT 'Ej: procesador, ram, almacenamiento',
    valor TEXT NOT NULL COMMENT 'Ej: Intel Core i5, 8GB DDR4',
    CONSTRAINT fk_spec_producto FOREIGN KEY (id_producto) REFERENCES productos(id_producto) ON DELETE CASCADE,
    INDEX idx_producto_spec (id_producto),
    INDEX idx_clave_spec (clave)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ==========================================
-- DATOS DE EJEMPLO (Insertando en el orden correcto por las FK)
-- ==========================================

-- 1. Insertar Marcas
INSERT INTO marcas (nombre, pais_origen) VALUES 
('Dell', 'Estados Unidos'),
('Samsung', 'Corea del Sur'),
('Logitech', 'Suiza');

-- 2. Insertar Categorías
INSERT INTO categorias (nombre, subcategoria, descripcion) VALUES 
('Laptops', 'Uso general', 'Computadoras portátiles para trabajo y estudio'),
('Smartphones', 'Gama alta', 'Teléfonos inteligentes de última generación'),
('Accesorios', 'Mouse', 'Dispositivos de puntero para computadoras');

-- 3. Insertar Productos (Usando los IDs generados: Dell=1, Samsung=2, Logitech=3 | Laptops=1, Smartphones=2, Accesorios=3)
INSERT INTO productos (id_marca, id_categoria, sku, nombre, modelo, descripcion, color, talla, precio_costo, precio_venta, stock_actual, stock_minimo, stock_maximo, estado, destacado) VALUES
(1, 1, 'LAP-DELL-001', 'Laptop Dell Inspiron 15', 'Inspiron 15 3520', 'Laptop con procesador Intel Core i5, ideal para trabajo y estudio.', 'Gris Platino', '15.6 pulgadas', 650.00, 899.99, 25, 5, 50, 'activo', TRUE),
(2, 2, 'CEL-SAM-001', 'Samsung Galaxy S24 Ultra', 'Galaxy S24 Ultra', 'Smartphone flagship con S Pen integrado y cámara de 200MP.', 'Titanio Negro', '6.8 pulgadas', 900.00, 1299.99, 40, 10, 100, 'activo', TRUE),
(3, 3, 'ACC-LOG-001', 'Mouse Logitech MX Master 3S', 'MX Master 3S', 'Mouse inalámbrico ergonómico de alta precisión para profesionales.', 'Gris Graphite', 'Estándar', 60.00, 99.99, 150, 20, 300, 'activo', FALSE);

-- 4. Insertar Imágenes (1FN: Una fila por imagen)
INSERT INTO producto_imagenes (id_producto, url_imagen, es_principal, orden_visual) VALUES
(1, 'https://ejemplo.com/img/dell1.jpg', TRUE, 1),
(1, 'https://ejemplo.com/img/dell2.jpg', FALSE, 2),
(2, 'https://ejemplo.com/img/samsung1.jpg', TRUE, 1),
(3, 'https://ejemplo.com/img/logitech1.jpg', TRUE, 1);

-- 5. Insertar Especificaciones Técnicas (1FN y 3FN: Modelo Clave-Valor)
INSERT INTO producto_especificaciones (id_producto, clave, valor) VALUES
-- Dell Inspiron
(1, 'procesador', 'Intel Core i5-1235U'),
(1, 'ram', '8GB DDR4'),
(1, 'almacenamiento', '256GB SSD NVMe'),
(1, 'pantalla', '15.6 FHD Anti-glare'),
(1, 'sistema_operativo', 'Windows 11 Home'),
-- Samsung S24
(2, 'procesador', 'Snapdragon 8 Gen 3'),
(2, 'ram', '12GB'),
(2, 'almacenamiento', '256GB'),
(2, 'camara_principal', '200MP'),
(2, 'bateria', '5000mAh'),
-- Logitech Mouse
(3, 'conexion', 'Bluetooth / USB Receiver'),
(3, 'dpi_maximo', '8000'),
(3, 'bateria', 'Hasta 70 días');