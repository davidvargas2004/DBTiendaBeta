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
-- DATOS DE EJEMPLO COMPLEMENTARIOS (SEED DATA) - MySQL
-- Total: ~170 registros lógicos, coherentes y vinculados a PostgreSQL
-- ==========================================

USE tiendabeta;

-- Deshabilitar verificación de claves foráneas temporalmente
SET FOREIGN_KEY_CHECKS = 0;

-- 1. MARCAS (10 registros)
INSERT INTO marcas (nombre, pais_origen) VALUES 
('Dell', 'Estados Unidos'),
('Samsung', 'Corea del Sur'),
('Logitech', 'Suiza'),
('Keychron', 'Hong Kong'),
('Apple', 'Estados Unidos'),
('ASUS', 'Taiwán'),
('Sony', 'Japón'),
('Xiaomi', 'China'),
('HP', 'Estados Unidos'),
('Lenovo', 'China');

-- 2. CATEGORÍAS (10 registros)
INSERT INTO categorias (nombre, subcategoria, descripcion) VALUES 
('Laptops', 'Uso general', 'Portátiles para trabajo y estudio'),
('Laptops', 'Gaming', 'Portátiles de alto rendimiento para juegos'),
('Smartphones', 'Gama alta', 'Teléfonos inteligentes flagship'),
('Smartphones', 'Gama media', 'Teléfonos con mejor relación calidad-precio'),
('Accesorios', 'Mouse', 'Dispositivos de puntero'),
('Accesorios', 'Teclados', 'Teclados mecánicos y de membrana'),
('Audio', 'Audífonos', 'Audífonos inalámbricos y con cable'),
('Monitores', 'Gaming', 'Pantallas de alta tasa de refresco'),
('Componentes', 'Almacenamiento', 'Discos SSD y HDD'),
('Wearables', 'Smartwatches', 'Relojes inteligentes');

-- 3. PRODUCTOS (50 registros) 
-- Los primeros 4 coinciden EXACTAMENTE con los productos en PostgreSQL
INSERT INTO productos (id_marca, id_categoria, sku, nombre, modelo, descripcion, color, talla, precio_costo, precio_venta, precio_oferta, stock_actual, stock_minimo, stock_maximo, ubicacion_almacen, estado, destacado) VALUES 
-- [1] Coincide con PG: LAP-DELL-001
(1, 1, 'LAP-DELL-001', 'Laptop Dell Inspiron 15', 'Inspiron 15 3520', 'Laptop con procesador Intel Core i5, ideal para trabajo y estudio.', 'Gris Platino', '15.6 pulgadas', 650.00, 899.99, 450.00, 25, 5, 50, 'Estante A-1', 'activo', TRUE),

-- [2] Coincide con PG: CEL-SAM-001
(2, 3, 'CEL-SAM-001', 'Samsung Galaxy S24 Ultra', 'Galaxy S24 Ultra', 'Smartphone flagship con S Pen integrado y cámara de 200MP.', 'Titanio Negro', '6.8 pulgadas', 900.00, 1299.99, 0.00, 40, 10, 100, 'Estante B-2', 'activo', TRUE),

-- [3] Coincide con PG: ACC-LOG-001
(3, 5, 'ACC-LOG-001', 'Mouse Logitech MX Master 3S', 'MX Master 3S', 'Mouse inalámbrico ergonómico de alta precisión para profesionales.', 'Gris Graphite', 'Estándar', 60.00, 99.99, 85.50, 150, 20, 300, 'Estante C-1', 'activo', TRUE),

-- [4] Coincide con PG: ACC-KEY-002
(4, 6, 'ACC-KEY-002', 'Teclado Mecánico Keychron K2', 'K2 V2', 'Teclado mecánico inalámbrico compacto con switches Gateron.', 'Negro', '75%', 55.00, 94.99, 75.00, 80, 15, 200, 'Estante C-2', 'activo', TRUE),

-- [5-50] Productos adicionales
(5, 1, 'LAP-APP-005', 'MacBook Air 13', 'M2 2023', 'Laptop ultradelgada con chip M2 de Apple.', 'Espacio Gris', '13.6 pulgadas', 950.00, 1199.00, 0.00, 30, 5, 60, 'Estante A-2', 'activo', TRUE),
(6, 2, 'LAP-ASU-006', 'ASUS ROG Strix G15', 'G513RM', 'Laptop gamer con RTX 4060 y pantalla 144Hz.', 'Negro Eclipse', '15.6 pulgadas', 1100.00, 1499.99, 1399.99, 15, 3, 40, 'Estante A-3', 'activo', TRUE),
(7, 7, 'AUD-SON-007', 'Sony WH-1000XM5', 'WH-1000XM5', 'Audífonos con cancelación de ruido líder en la industria.', 'Plata', 'Única', 250.00, 349.99, 0.00, 60, 10, 150, 'Estante D-1', 'activo', TRUE),
(8, 4, 'CEL-XIA-008', 'Xiaomi Redmi Note 13 Pro', 'Redmi Note 13 Pro', 'Gama media con cámara de 200MP y carga rápida.', 'Azul', '6.67 pulgadas', 220.00, 299.99, 279.99, 100, 20, 250, 'Estante B-3', 'activo', TRUE),
(9, 8, 'MON-HP-009', 'HP X24ih', 'X24ih', 'Monitor gaming 144Hz 1ms IPS.', 'Negro', '24 pulgadas', 130.00, 189.99, 0.00, 45, 10, 100, 'Estante E-1', 'activo', FALSE),
(10, 9, 'COM-LEN-010', 'Lenovo SSD 1TB', 'SL700', 'Disco sólido M.2 NVMe de alta velocidad.', 'N/A', 'M.2 2280', 45.00, 79.99, 0.00, 200, 30, 500, 'Estante F-1', 'activo', FALSE),
(5, 10, 'WEA-APP-011', 'Apple Watch Series 9', 'Series 9', 'Reloj inteligente con sensor de temperatura y doble toque.', 'Medianoche', '45mm', 350.00, 429.00, 0.00, 40, 8, 80, 'Estante G-1', 'activo', TRUE),
(2, 4, 'CEL-SAM-012', 'Samsung Galaxy A54', 'A54 5G', 'Gama media premium con excelente cámara y batería.', 'Awesome Violet', '6.4 pulgadas', 250.00, 349.99, 329.99, 75, 15, 150, 'Estante B-4', 'activo', TRUE),
(3, 5, 'ACC-LOG-013', 'Logitech G502 Hero', 'G502 Hero', 'Mouse gamer con pesos ajustables y 11 botones.', 'Negro', 'Estándar', 40.00, 69.99, 0.00, 90, 15, 200, 'Estante C-3', 'activo', FALSE),
(1, 1, 'LAP-DELL-014', 'Dell XPS 13', 'XPS 13 9315', 'Ultrabook premium con pantalla InfinityEdge.', 'Blanco Alpino', '13.4 pulgadas', 1100.00, 1399.99, 0.00, 12, 3, 30, 'Estante A-4', 'activo', TRUE),
(6, 2, 'LAP-ASU-015', 'ASUS Zenbook 14', 'UX3402', 'Laptop delgada con pantalla OLED.', 'Azul Ponderosa', '14 pulgadas', 800.00, 1099.99, 999.99, 20, 5, 50, 'Estante A-5', 'activo', TRUE),
(7, 7, 'AUD-SON-016', 'Sony WF-1000XM4', 'WF-1000XM4', 'Audífonos true wireless con cancelación de ruido.', 'Negro', 'Única', 180.00, 249.99, 0.00, 55, 10, 120, 'Estante D-2', 'activo', TRUE),
(8, 4, 'CEL-XIA-017', 'Xiaomi 13T', '13T', 'Smartphone con cámaras Leica y pantalla 144Hz.', 'Negro', '6.67 pulgadas', 450.00, 599.99, 0.00, 35, 8, 80, 'Estante B-5', 'activo', FALSE),
(9, 8, 'MON-HP-018', 'HP M27f', 'M27f', 'Monitor FHD de 27 pulgadas con bordes ultradelgados.', 'Plata', '27 pulgadas', 110.00, 159.99, 149.99, 60, 10, 150, 'Estante E-2', 'activo', TRUE),
(10, 9, 'COM-LEN-019', 'Lenovo RAM 16GB', 'ThinkSystem', 'Memoria RAM DDR4 3200MHz para servidores y PC.', 'N/A', '16GB', 35.00, 59.99, 0.00, 150, 25, 400, 'Estante F-2', 'activo', FALSE),
(4, 6, 'ACC-KEY-020', 'Keychron K8 Pro', 'K8 Pro', 'Teclado mecánico 75% con QMK/VIA.', 'Blanco', '75%', 70.00, 109.99, 0.00, 40, 10, 100, 'Estante C-4', 'activo', TRUE),
(5, 10, 'WEA-APP-021', 'Apple Watch SE', 'SE 2023', 'Reloj inteligente esencial con seguimiento de actividad.', 'Estelar', '40mm', 200.00, 279.00, 249.00, 50, 10, 100, 'Estante G-2', 'activo', TRUE),
(1, 1, 'LAP-DELL-022', 'Dell Latitude 5430', '5430', 'Laptop empresarial resistente y segura.', 'Negro', '14 pulgadas', 750.00, 999.99, 0.00, 18, 5, 40, 'Estante A-6', 'activo', FALSE),
(2, 3, 'CEL-SAM-023', 'Samsung Galaxy Z Flip 5', 'Z Flip 5', 'Smartphone plegable con pantalla Cover grande.', 'Crema', 'Plegado', 800.00, 1099.99, 0.00, 25, 5, 60, 'Estante B-6', 'activo', TRUE),
(3, 6, 'ACC-LOG-024', 'Logitech MX Keys', 'MX Keys', 'Teclado inalámbrico iluminado para creadores.', 'Gris', 'Completo', 70.00, 119.99, 99.99, 65, 15, 150, 'Estante C-5', 'activo', TRUE),
(6, 8, 'MON-ASU-025', 'ASUS TUF Gaming 27', 'VG27AQ', 'Monitor 1440p 165Hz con G-Sync Compatible.', 'Negro', '27 pulgadas', 220.00, 329.99, 0.00, 30, 5, 80, 'Estante E-3', 'activo', TRUE),
(7, 7, 'AUD-SON-026', 'Sony LinkBuds S', 'LinkBuds S', 'Audífonos true wireless ultraligeros.', 'Blanco', 'Única', 140.00, 199.99, 179.99, 45, 10, 100, 'Estante D-3', 'activo', FALSE),
(8, 3, 'CEL-XIA-027', 'Xiaomi 13 Pro', '13 Pro', 'Flagship con cámara Leica de 1 pulgada.', 'Blanco Cerámico', '6.73 pulgadas', 700.00, 999.99, 0.00, 20, 5, 50, 'Estante B-7', 'activo', TRUE),
(9, 9, 'COM-HP-028', 'HP SSD 500GB', 'EX900', 'Disco sólido M.2 NVMe de entrada.', 'N/A', 'M.2 2280', 25.00, 49.99, 0.00, 120, 20, 300, 'Estante F-3', 'activo', FALSE),
(10, 10, 'WEA-LEN-029', 'Lenovo Smart Watch', 'S2 Pro', 'Reloj inteligente con GPS y monitor de oxígeno.', 'Negro', '46mm', 40.00, 79.99, 59.99, 80, 15, 200, 'Estante G-3', 'activo', TRUE),
(4, 6, 'ACC-KEY-030', 'Keychron Q1 Pro', 'Q1 Pro', 'Teclado mecánico premium 75% con carcasa de aluminio.', 'Negro', '75%', 150.00, 199.99, 0.00, 15, 3, 40, 'Estante C-6', 'activo', TRUE),
(5, 1, 'LAP-APP-031', 'MacBook Pro 14', 'M3 Pro', 'Laptop profesional con chip M3 Pro y Liquid Retina XDR.', 'Gris Espacial', '14.2 pulgadas', 1600.00, 1999.00, 0.00, 10, 2, 25, 'Estante A-7', 'activo', TRUE),
(1, 2, 'LAP-DELL-032', 'Dell G15 Gaming', 'G15 5530', 'Laptop gamer accesible con RTX 4050.', 'Verde Oscuro', '15.6 pulgadas', 700.00, 949.99, 899.99, 22, 5, 50, 'Estante A-8', 'activo', TRUE),
(2, 4, 'CEL-SAM-033', 'Samsung Galaxy A14', 'A14 5G', 'Smartphone de entrada con conectividad 5G.', 'Verde', '6.6 pulgadas', 130.00, 179.99, 159.99, 150, 30, 400, 'Estante B-8', 'activo', FALSE),
(3, 5, 'ACC-LOG-034', 'Logitech G Pro X Superlight', 'Superlight', 'Mouse gamer ultraligero de competición.', 'Blanco', 'Estándar', 100.00, 159.99, 0.00, 35, 8, 80, 'Estante C-7', 'activo', TRUE),
(6, 1, 'LAP-ASU-035', 'ASUS Vivobook 15', 'Vivobook 15', 'Laptop versátil para el día a día.', 'Azul Tranquilo', '15.6 pulgadas', 400.00, 549.99, 499.99, 40, 10, 100, 'Estante A-9', 'activo', TRUE),
(7, 7, 'AUD-SON-036', 'Sony SRS-XB13', 'SRS-XB13', 'Parlante Bluetooth portátil y resistente al agua.', 'Azul', 'Única', 40.00, 59.99, 0.00, 90, 15, 200, 'Estante D-4', 'activo', FALSE),
(8, 4, 'CEL-XIA-037', 'Xiaomi Poco X5 Pro', 'Poco X5 Pro', 'Smartphone enfocado en rendimiento y gaming móvil.', 'Amarillo', '6.67 pulgadas', 230.00, 329.99, 299.99, 60, 12, 150, 'Estante B-9', 'activo', TRUE),
(9, 8, 'MON-HP-038', 'HP E24 G5', 'E24 G5', 'Monitor empresarial FHD de 23.8 pulgadas.', 'Negro', '23.8 pulgadas', 100.00, 149.99, 0.00, 50, 10, 120, 'Estante E-4', 'activo', FALSE),
(10, 9, 'COM-LEN-039', 'Lenovo Fuente 65W', '65W USB-C', 'Cargador de laptop universal USB-C.', 'Negro', '65W', 15.00, 29.99, 0.00, 200, 40, 500, 'Estante F-4', 'activo', TRUE),
(4, 5, 'ACC-KEY-040', 'Keychron Mouse K3', 'K3', 'Mouse ergonómico vertical inalámbrico.', 'Gris', 'Única', 35.00, 54.99, 0.00, 70, 15, 150, 'Estante C-8', 'activo', TRUE),
(5, 10, 'WEA-APP-041', 'Apple Watch Ultra 2', 'Ultra 2', 'Reloj inteligente todoterreno para deportes extremos.', 'Titanio', '49mm', 700.00, 899.00, 0.00, 15, 3, 30, 'Estante G-4', 'activo', TRUE),
(1, 1, 'LAP-DELL-042', 'Dell Precision 3581', '3581', 'Workstation móvil para profesionales creativos.', 'Negro', '15.6 pulgadas', 1300.00, 1699.99, 0.00, 8, 2, 20, 'Estante A-10', 'activo', FALSE),
(2, 3, 'CEL-SAM-043', 'Samsung Galaxy Tab S9', 'Tab S9', 'Tablet Android premium con S Pen incluido.', 'Gris', '11 pulgadas', 600.00, 799.99, 749.99, 30, 6, 70, 'Estante B-10', 'activo', TRUE),
(3, 6, 'ACC-LOG-044', 'Logitech G915 TKL', 'G915 TKL', 'Teclado mecánico gaming inalámbrico de perfil bajo.', 'Negro', 'TKL', 160.00, 229.99, 0.00, 25, 5, 60, 'Estante C-9', 'activo', TRUE),
(6, 2, 'LAP-ASU-045', 'ASUS TUF Dash F15', 'Dash F15', 'Laptop gamer delgada con RTX 4060.', 'Gris Eclipse', '15.6 pulgadas', 950.00, 1299.99, 1199.99, 18, 4, 45, 'Estante A-11', 'activo', TRUE),
(7, 7, 'AUD-SON-046', 'Sony INZONE H9', 'INZONE H9', 'Audífonos gaming con cancelación de ruido.', 'Blanco', 'Única', 200.00, 299.99, 0.00, 20, 5, 50, 'Estante D-5', 'activo', FALSE),
(8, 3, 'CEL-XIA-047', 'Xiaomi 13 Lite', '13 Lite', 'Smartphone delgado y ligero con cámara selfie dual.', 'Negro', '6.55 pulgadas', 300.00, 399.99, 379.99, 45, 10, 100, 'Estante B-11', 'activo', TRUE),
(9, 9, 'COM-HP-048', 'HP Webcam 1080p', '1080p', 'Cámara web con privacidad integrada y micrófono dual.', 'Negro', 'Única', 30.00, 49.99, 0.00, 110, 20, 250, 'Estante F-5', 'activo', TRUE),
(10, 10, 'WEA-LEN-049', 'Lenovo ThinkBand', 'ThinkBand', 'Pulsera de actividad con monitor de sueño.', 'Negro', 'Única', 25.00, 49.99, 39.99, 90, 20, 200, 'Estante G-5', 'activo', FALSE),
(4, 6, 'ACC-KEY-050', 'Keychron K10 Pro', 'K10 Pro', 'Teclado mecánico inalámbrico formato completo (100%).', 'Blanco', '100%', 85.00, 119.99, 0.00, 35, 8, 80, 'Estante C-10', 'activo', TRUE);

-- 4. PRODUCTO_IMAGENES (50 registros, 1 por producto)
-- Ahora usamos subconsultas para obtener los IDs correctos basados en SKU
INSERT INTO producto_imagenes (id_producto, url_imagen, es_principal, orden_visual) 
SELECT p.id_producto, CONCAT('https://cdn.tiendabeta.com/img/', p.sku, '_1.jpg'), TRUE, 1
FROM productos p
WHERE p.sku IN (
    'LAP-DELL-001', 'CEL-SAM-001', 'ACC-LOG-001', 'ACC-KEY-002',
    'LAP-APP-005', 'LAP-ASU-006', 'AUD-SON-007', 'CEL-XIA-008',
    'MON-HP-009', 'COM-LEN-010', 'WEA-APP-011', 'CEL-SAM-012',
    'ACC-LOG-013', 'LAP-DELL-014', 'LAP-ASU-015', 'AUD-SON-016',
    'CEL-XIA-017', 'MON-HP-018', 'COM-LEN-019', 'ACC-KEY-020',
    'WEA-APP-021', 'LAP-DELL-022', 'CEL-SAM-023', 'ACC-LOG-024',
    'MON-ASU-025', 'AUD-SON-026', 'CEL-XIA-027', 'COM-HP-028',
    'WEA-LEN-029', 'ACC-KEY-030', 'LAP-APP-031', 'LAP-DELL-032',
    'CEL-SAM-033', 'ACC-LOG-034', 'LAP-ASU-035', 'AUD-SON-036',
    'CEL-XIA-037', 'MON-HP-038', 'COM-LEN-039', 'ACC-KEY-040',
    'WEA-APP-041', 'LAP-DELL-042', 'CEL-SAM-043', 'ACC-LOG-044',
    'LAP-ASU-045', 'AUD-SON-046', 'CEL-XIA-047', 'COM-HP-048',
    'WEA-LEN-049', 'ACC-KEY-050'
);

-- 5. PRODUCTO_ESPECIFICACIONES (100 registros, 2 por producto)
-- Usamos subconsultas para obtener los IDs correctos
INSERT INTO producto_especificaciones (id_producto, clave, valor) VALUES 
-- Producto 1 (LAP-DELL-001)
((SELECT id_producto FROM productos WHERE sku = 'LAP-DELL-001'), 'procesador', 'Intel Core i5-1235U'),
((SELECT id_producto FROM productos WHERE sku = 'LAP-DELL-001'), 'ram', '8GB DDR4'),
-- Producto 2 (CEL-SAM-001)
((SELECT id_producto FROM productos WHERE sku = 'CEL-SAM-001'), 'procesador', 'Snapdragon 8 Gen 3'),
((SELECT id_producto FROM productos WHERE sku = 'CEL-SAM-001'), 'camara', '200MP Principal'),
-- Producto 3 (ACC-LOG-001)
((SELECT id_producto FROM productos WHERE sku = 'ACC-LOG-001'), 'conexion', 'Bluetooth / USB Receiver'),
((SELECT id_producto FROM productos WHERE sku = 'ACC-LOG-001'), 'dpi_maximo', '8000'),
-- Producto 4 (ACC-KEY-002)
((SELECT id_producto FROM productos WHERE sku = 'ACC-KEY-002'), 'switches', 'Gateron G Pro Brown'),
((SELECT id_producto FROM productos WHERE sku = 'ACC-KEY-002'), 'conectividad', 'Bluetooth 5.1 / USB-C'),
-- Producto 5 (LAP-APP-005)
((SELECT id_producto FROM productos WHERE sku = 'LAP-APP-005'), 'chip', 'Apple M2'),
((SELECT id_producto FROM productos WHERE sku = 'LAP-APP-005'), 'almacenamiento', '256GB SSD'),
-- Producto 6 (LAP-ASU-006)
((SELECT id_producto FROM productos WHERE sku = 'LAP-ASU-006'), 'gpu', 'NVIDIA RTX 4060 8GB'),
((SELECT id_producto FROM productos WHERE sku = 'LAP-ASU-006'), 'pantalla', '15.6" FHD 144Hz'),
-- Producto 7 (AUD-SON-007)
((SELECT id_producto FROM productos WHERE sku = 'AUD-SON-007'), 'tipo', 'Over-ear'),
((SELECT id_producto FROM productos WHERE sku = 'AUD-SON-007'), 'cancelacion_ruido', 'Activa (ANC)'),
-- Producto 8 (CEL-XIA-008)
((SELECT id_producto FROM productos WHERE sku = 'CEL-XIA-008'), 'bateria', '5000mAh'),
((SELECT id_producto FROM productos WHERE sku = 'CEL-XIA-008'), 'carga', '67W Turbo'),
-- Producto 9 (MON-HP-009)
((SELECT id_producto FROM productos WHERE sku = 'MON-HP-009'), 'resolucion', '1920x1080 FHD'),
((SELECT id_producto FROM productos WHERE sku = 'MON-HP-009'), 'tasa_refresco', '144Hz'),
-- Producto 10 (COM-LEN-010)
((SELECT id_producto FROM productos WHERE sku = 'COM-LEN-010'), 'interfaz', 'PCIe Gen3 x4'),
((SELECT id_producto FROM productos WHERE sku = 'COM-LEN-010'), 'velocidad_lectura', '3200 MB/s'),
-- Producto 11 (WEA-APP-011)
((SELECT id_producto FROM productos WHERE sku = 'WEA-APP-011'), 'sensor', 'Temperatura corporal'),
((SELECT id_producto FROM productos WHERE sku = 'WEA-APP-011'), 'resistencia_agua', 'WR50'),
-- Producto 12 (CEL-SAM-012)
((SELECT id_producto FROM productos WHERE sku = 'CEL-SAM-012'), 'pantalla', 'Super AMOLED'),
((SELECT id_producto FROM productos WHERE sku = 'CEL-SAM-012'), 'proteccion', 'Gorilla Glass 5'),
-- Producto 13 (ACC-LOG-013)
((SELECT id_producto FROM productos WHERE sku = 'ACC-LOG-013'), 'botones_programables', '8'),
((SELECT id_producto FROM productos WHERE sku = 'ACC-LOG-013'), 'peso', '121g'),
-- Producto 14 (LAP-DELL-014)
((SELECT id_producto FROM productos WHERE sku = 'LAP-DELL-014'), 'peso', '1.17 kg'),
((SELECT id_producto FROM productos WHERE sku = 'LAP-DELL-014'), 'bateria', 'Hasta 12 horas'),
-- Producto 15 (LAP-ASU-015)
((SELECT id_producto FROM productos WHERE sku = 'LAP-ASU-015'), 'pantalla', '2.8K OLED'),
((SELECT id_producto FROM productos WHERE sku = 'LAP-ASU-015'), 'certificacion', 'Intel Evo'),
-- Producto 16 (AUD-SON-016)
((SELECT id_producto FROM productos WHERE sku = 'AUD-SON-016'), 'bateria', '8 horas'),
((SELECT id_producto FROM productos WHERE sku = 'AUD-SON-016'), 'codec', 'LDAC, AAC, SBC'),
-- Producto 17 (CEL-XIA-017)
((SELECT id_producto FROM productos WHERE sku = 'CEL-XIA-017'), 'pantalla', 'Crystal AMOLED 144Hz'),
((SELECT id_producto FROM productos WHERE sku = 'CEL-XIA-017'), 'camara', '50MP con OIS'),
-- Producto 18 (MON-HP-018)
((SELECT id_producto FROM productos WHERE sku = 'MON-HP-018'), 'panel', 'IPS'),
((SELECT id_producto FROM productos WHERE sku = 'MON-HP-018'), 'brillo', '300 nits'),
-- Producto 19 (COM-LEN-019)
((SELECT id_producto FROM productos WHERE sku = 'COM-LEN-019'), 'tipo', 'DDR4'),
((SELECT id_producto FROM productos WHERE sku = 'COM-LEN-019'), 'velocidad', '3200 MHz'),
-- Producto 20 (ACC-KEY-020)
((SELECT id_producto FROM productos WHERE sku = 'ACC-KEY-020'), 'formato', '75%'),
((SELECT id_producto FROM productos WHERE sku = 'ACC-KEY-020'), 'hot_swappable', 'Sí'),
-- Producto 21 (WEA-APP-021)
((SELECT id_producto FROM productos WHERE sku = 'WEA-APP-021'), 'gps', 'GPS de doble frecuencia'),
((SELECT id_producto FROM productos WHERE sku = 'WEA-APP-021'), 'bateria', 'Hasta 18 horas'),
-- Producto 22 (LAP-DELL-022)
((SELECT id_producto FROM productos WHERE sku = 'LAP-DELL-022'), 'certificacion', 'MIL-STD-810H'),
((SELECT id_producto FROM productos WHERE sku = 'LAP-DELL-022'), 'seguridad', 'Lector de huellas'),
-- Producto 23 (CEL-SAM-023)
((SELECT id_producto FROM productos WHERE sku = 'CEL-SAM-023'), 'bisagra', 'Flex Mode'),
((SELECT id_producto FROM productos WHERE sku = 'CEL-SAM-023'), 'camara_frontal', '10MP'),
-- Producto 24 (ACC-LOG-024)
((SELECT id_producto FROM productos WHERE sku = 'ACC-LOG-024'), 'iluminacion', 'Smart Backlighting'),
((SELECT id_producto FROM productos WHERE sku = 'ACC-LOG-024'), 'bateria', 'Hasta 1 mes'),
-- Producto 25 (MON-ASU-025)
((SELECT id_producto FROM productos WHERE sku = 'MON-ASU-025'), 'tecnologia', 'Fast IPS'),
((SELECT id_producto FROM productos WHERE sku = 'MON-ASU-025'), 'hdr', 'HDR10'),
-- Producto 26 (AUD-SON-026)
((SELECT id_producto FROM productos WHERE sku = 'AUD-SON-026'), 'peso', '4.8g por audífono'),
((SELECT id_producto FROM productos WHERE sku = 'AUD-SON-026'), 'carga_inalambrica', 'Sí'),
-- Producto 27 (CEL-XIA-027)
((SELECT id_producto FROM productos WHERE sku = 'CEL-XIA-027'), 'lentes', 'Leica Summicron'),
((SELECT id_producto FROM productos WHERE sku = 'CEL-XIA-027'), 'video', '8K 24fps'),
-- Producto 28 (COM-HP-028)
((SELECT id_producto FROM productos WHERE sku = 'COM-HP-028'), 'formato', 'M.2 2280'),
((SELECT id_producto FROM productos WHERE sku = 'COM-HP-028'), 'nand', '3D TLC'),
-- Producto 29 (WEA-LEN-029)
((SELECT id_producto FROM productos WHERE sku = 'WEA-LEN-029'), 'pantalla', '1.4" TFT'),
((SELECT id_producto FROM productos WHERE sku = 'WEA-LEN-029'), 'sensores', 'SpO2, Frecuencia cardiaca'),
-- Producto 30 (ACC-KEY-030)
((SELECT id_producto FROM productos WHERE sku = 'ACC-KEY-030'), 'carcasa', 'Aluminio CNC'),
((SELECT id_producto FROM productos WHERE sku = 'ACC-KEY-030'), 'qmk_via', 'Soporte nativo'),
-- Producto 31 (LAP-APP-031)
((SELECT id_producto FROM productos WHERE sku = 'LAP-APP-031'), 'pantalla', 'Liquid Retina XDR'),
((SELECT id_producto FROM productos WHERE sku = 'LAP-APP-031'), 'puertos', 'HDMI, SD, Thunderbolt 4'),
-- Producto 32 (LAP-DELL-032)
((SELECT id_producto FROM productos WHERE sku = 'LAP-DELL-032'), 'refrigeracion', 'Cámara de vapor'),
((SELECT id_producto FROM productos WHERE sku = 'LAP-DELL-032'), 'teclado', 'Retroiluminado 4 zonas'),
-- Producto 33 (CEL-SAM-033)
((SELECT id_producto FROM productos WHERE sku = 'CEL-SAM-033'), 'red', '5G'),
((SELECT id_producto FROM productos WHERE sku = 'CEL-SAM-033'), 'bateria', '5000mAh'),
-- Producto 34 (ACC-LOG-034)
((SELECT id_producto FROM productos WHERE sku = 'ACC-LOG-034'), 'peso', '63g'),
((SELECT id_producto FROM productos WHERE sku = 'ACC-LOG-034'), 'sensor', 'HERO 25K'),
-- Producto 35 (LAP-ASU-035)
((SELECT id_producto FROM productos WHERE sku = 'LAP-ASU-035'), 'peso', '1.8 kg'),
((SELECT id_producto FROM productos WHERE sku = 'LAP-ASU-035'), 'audio', 'Harman Kardon'),
-- Producto 36 (AUD-SON-036)
((SELECT id_producto FROM productos WHERE sku = 'AUD-SON-036'), 'potencia', '16W'),
((SELECT id_producto FROM productos WHERE sku = 'AUD-SON-036'), 'resistencia', 'IP67'),
-- Producto 37 (CEL-XIA-037)
((SELECT id_producto FROM productos WHERE sku = 'CEL-XIA-037'), 'carga', '67W'),
((SELECT id_producto FROM productos WHERE sku = 'CEL-XIA-037'), 'nfc', 'Sí'),
-- Producto 38 (MON-HP-038)
((SELECT id_producto FROM productos WHERE sku = 'MON-HP-038'), 'conectividad', 'VGA, HDMI, DisplayPort'),
((SELECT id_producto FROM productos WHERE sku = 'MON-HP-038'), 'ajuste_altura', 'Sí'),
-- Producto 39 (COM-LEN-039)
((SELECT id_producto FROM productos WHERE sku = 'COM-LEN-039'), 'compatibilidad', 'USB-C Universal'),
((SELECT id_producto FROM productos WHERE sku = 'COM-LEN-039'), 'proteccion', 'Sobrecarga y cortocircuito'),
-- Producto 40 (ACC-KEY-040)
((SELECT id_producto FROM productos WHERE sku = 'ACC-KEY-040'), 'ergonomia', 'Vertical 60 grados'),
((SELECT id_producto FROM productos WHERE sku = 'ACC-KEY-040'), 'bateria', 'Recargable USB-C'),
-- Producto 41 (WEA-APP-041)
((SELECT id_producto FROM productos WHERE sku = 'WEA-APP-041'), 'material', 'Titanio de grado aeroespacial'),
((SELECT id_producto FROM productos WHERE sku = 'WEA-APP-041'), 'sirena', '86 decibelios'),
-- Producto 42 (LAP-DELL-042)
((SELECT id_producto FROM productos WHERE sku = 'LAP-DELL-042'), 'gpu', 'NVIDIA RTX 2000 Ada'),
((SELECT id_producto FROM productos WHERE sku = 'LAP-DELL-042'), 'ram_maxima', '64GB DDR5'),
-- Producto 43 (CEL-SAM-043)
((SELECT id_producto FROM productos WHERE sku = 'CEL-SAM-043'), 'accesorio', 'S Pen incluido'),
((SELECT id_producto FROM productos WHERE sku = 'CEL-SAM-043'), 'resistencia', 'IP68'),
-- Producto 44 (ACC-LOG-044)
((SELECT id_producto FROM productos WHERE sku = 'ACC-LOG-044'), 'perfil', 'Ultra bajo (Low-profile)'),
((SELECT id_producto FROM productos WHERE sku = 'ACC-LOG-044'), 'switches', 'GL Tactile'),
-- Producto 45 (LAP-ASU-045)
((SELECT id_producto FROM productos WHERE sku = 'LAP-ASU-045'), 'bateria', '90Wh'),
((SELECT id_producto FROM productos WHERE sku = 'LAP-ASU-045'), 'carga_rapida', '50% en 30 min'),
-- Producto 46 (AUD-SON-046)
((SELECT id_producto FROM productos WHERE sku = 'AUD-SON-046'), 'microfono', 'Con cancelación de ruido'),
((SELECT id_producto FROM productos WHERE sku = 'AUD-SON-046'), 'conectividad', '2.4GHz / Bluetooth'),
-- Producto 47 (CEL-XIA-047)
((SELECT id_producto FROM productos WHERE sku = 'CEL-XIA-047'), 'peso', '171g'),
((SELECT id_producto FROM productos WHERE sku = 'CEL-XIA-047'), 'pantalla', 'AMOLED 120Hz'),
-- Producto 48 (COM-HP-048)
((SELECT id_producto FROM productos WHERE sku = 'COM-HP-048'), 'resolucion', '1920x1080'),
((SELECT id_producto FROM productos WHERE sku = 'COM-HP-048'), 'campo_vision', '78 grados'),
-- Producto 49 (WEA-LEN-049)
((SELECT id_producto FROM productos WHERE sku = 'WEA-LEN-049'), 'resistencia', '5 ATM'),
((SELECT id_producto FROM productos WHERE sku = 'WEA-LEN-049'), 'notificaciones', 'Sí'),
-- Producto 50 (ACC-KEY-050)
((SELECT id_producto FROM productos WHERE sku = 'ACC-KEY-050'), 'formato', '100% (Full size)'),
((SELECT id_producto FROM productos WHERE sku = 'ACC-KEY-050'), 'teclas', 'Mac y Windows');

-- Reactivar verificación de claves foráneas
SET FOREIGN_KEY_CHECKS = 1;

-- Verificar que los datos se cargaron correctamente
SELECT 'Marcas cargadas:' AS info, COUNT(*) AS total FROM marcas
UNION ALL
SELECT 'Categorías cargadas:', COUNT(*) FROM categorias
UNION ALL
SELECT 'Productos cargados:', COUNT(*) FROM productos
UNION ALL
SELECT 'Imágenes cargadas:', COUNT(*) FROM producto_imagenes
UNION ALL
SELECT 'Especificaciones cargadas:', COUNT(*) FROM producto_especificaciones;