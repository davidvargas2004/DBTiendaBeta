/* ==========================================
   TIENDABETA DASHBOARD - JAVASCRIPT
   ========================================== */

// ==========================================
// DATOS MOCK (Simulando respuestas de API)
// En producción, estos vendrían de:
// - MySQL: /api/productos, /api/marcas, /api/categorias
// - PostgreSQL: /api/pedidos, /api/ventas, /api/clientes
// ==========================================

const mockData = {
    productos: [
        { id: 1, sku: 'LAP-DELL-001', nombre: 'Laptop Dell Inspiron 15', categoria: 'Laptops', precio: 899.99, stock: 25, stock_min: 5, estado: 'activo', destacado: true },
        { id: 2, sku: 'CEL-SAM-001', nombre: 'Samsung Galaxy S24 Ultra', categoria: 'Smartphones', precio: 1299.99, stock: 40, stock_min: 10, estado: 'activo', destacado: true },
        { id: 3, sku: 'ACC-LOG-001', nombre: 'Mouse Logitech MX Master 3S', categoria: 'Accesorios', precio: 99.99, stock: 150, stock_min: 20, estado: 'activo', destacado: true },
        { id: 4, sku: 'ACC-KEY-002', nombre: 'Teclado Mecánico Keychron K2', categoria: 'Accesorios', precio: 94.99, stock: 80, stock_min: 15, estado: 'activo', destacado: true },
        { id: 5, sku: 'LAP-APP-005', nombre: 'MacBook Air 13 M2', categoria: 'Laptops', precio: 1199.00, stock: 30, stock_min: 5, estado: 'activo', destacado: true },
        { id: 6, sku: 'LAP-ASU-006', nombre: 'ASUS ROG Strix G15', categoria: 'Laptops', precio: 1499.99, stock: 15, stock_min: 3, estado: 'activo', destacado: true },
        { id: 7, sku: 'AUD-SON-007', nombre: 'Sony WH-1000XM5', categoria: 'Audio', precio: 349.99, stock: 60, stock_min: 10, estado: 'activo', destacado: true },
        { id: 8, sku: 'CEL-XIA-008', nombre: 'Xiaomi Redmi Note 13 Pro', categoria: 'Smartphones', precio: 299.99, stock: 100, stock_min: 20, estado: 'activo', destacado: false },
        { id: 9, sku: 'MON-HP-009', nombre: 'HP X24ih Gaming', categoria: 'Monitores', precio: 189.99, stock: 45, stock_min: 10, estado: 'activo', destacado: false },
        { id: 10, sku: 'COM-LEN-010', nombre: 'Lenovo SSD 1TB', categoria: 'Componentes', precio: 79.99, stock: 200, stock_min: 30, estado: 'activo', destacado: false },
        { id: 11, sku: 'WEA-APP-011', nombre: 'Apple Watch Series 9', categoria: 'Wearables', precio: 429.00, stock: 40, stock_min: 8, estado: 'activo', destacado: true },
        { id: 12, sku: 'CEL-SAM-012', nombre: 'Samsung Galaxy A54', categoria: 'Smartphones', precio: 349.99, stock: 75, stock_min: 15, estado: 'activo', destacado: true },
        { id: 13, sku: 'ACC-LOG-013', nombre: 'Logitech G502 Hero', categoria: 'Accesorios', precio: 69.99, stock: 90, stock_min: 15, estado: 'activo', destacado: false },
        { id: 14, sku: 'LAP-DELL-014', nombre: 'Dell XPS 13', categoria: 'Laptops', precio: 1399.99, stock: 12, stock_min: 3, estado: 'activo', destacado: true },
        { id: 15, sku: 'LAP-ASU-015', nombre: 'ASUS Zenbook 14', categoria: 'Laptops', precio: 1099.99, stock: 20, stock_min: 5, estado: 'activo', destacado: true },
        { id: 16, sku: 'AUD-SON-016', nombre: 'Sony WF-1000XM4', categoria: 'Audio', precio: 249.99, stock: 55, stock_min: 10, estado: 'activo', destacado: true },
        { id: 17, sku: 'CEL-XIA-017', nombre: 'Xiaomi 13T', categoria: 'Smartphones', precio: 599.99, stock: 35, stock_min: 8, estado: 'activo', destacado: false },
        { id: 18, sku: 'MON-HP-018', nombre: 'HP M27f', categoria: 'Monitores', precio: 159.99, stock: 60, stock_min: 10, estado: 'activo', destacado: true },
        { id: 19, sku: 'COM-LEN-019', nombre: 'Lenovo RAM 16GB', categoria: 'Componentes', precio: 59.99, stock: 150, stock_min: 25, estado: 'activo', destacado: false },
        { id: 20, sku: 'ACC-KEY-020', nombre: 'Keychron K8 Pro', categoria: 'Accesorios', precio: 109.99, stock: 40, stock_min: 10, estado: 'activo', destacado: true }
    ],
    pedidos: [
        { id: 1, cliente: 'Juan Pérez', fecha: '2024-10-25', total: 1070.99, estado: 'entregado' },
        { id: 2, cliente: 'María Gómez', fecha: '2024-10-27', total: 1299.99, estado: 'entregado' },
        { id: 3, cliente: 'Carlos Rodríguez', fecha: '2024-10-28', total: 189.98, estado: 'entregado' },
        { id: 4, cliente: 'Ana Martínez', fecha: '2024-10-29', total: 899.99, estado: 'cancelado' },
        { id: 5, cliente: 'Luis Fernández', fecha: '2024-10-30', total: 150.00, estado: 'entregado' },
        { id: 6, cliente: 'Sofía López', fecha: '2024-10-31', total: 2599.98, estado: 'entregado' },
        { id: 7, cliente: 'Diego Ramírez', fecha: '2024-11-01', total: 89.99, estado: 'entregado' },
        { id: 8, cliente: 'Valentina Torres', fecha: '2024-11-02', total: 1299.99, estado: 'enviado' },
        { id: 9, cliente: 'Andrés Flores', fecha: '2024-11-03', total: 450.00, estado: 'procesando' },
        { id: 10, cliente: 'Camila Vargas', fecha: '2024-11-04', total: 0.00, estado: 'pendiente' },
        { id: 11, cliente: 'Juan Pérez', fecha: '2024-11-04', total: 171.00, estado: 'pendiente' },
        { id: 12, cliente: 'María Gómez', fecha: '2024-11-04', total: 150.00, estado: 'procesando' },
        { id: 13, cliente: 'Sofía López', fecha: '2024-11-04', total: 99.99, estado: 'enviado' },
        { id: 14, cliente: 'Diego Ramírez', fecha: '2024-11-04', total: 0.00, estado: 'pendiente' },
        { id: 15, cliente: 'Carlos Rodríguez', fecha: '2024-11-04', total: 0.00, estado: 'pendiente' }
    ],
    ventas: [
        { id: 1, factura: 'FAC-20241025-00001', pedido: 1, fecha: '2024-10-25', subtotal: 1070.99, impuestos: 203.49, descuento: 0.00, total: 1274.48, estado: 'pagada' },
        { id: 2, factura: 'FAC-20241027-00002', pedido: 2, fecha: '2024-10-27', subtotal: 1299.99, impuestos: 247.00, descuento: 0.00, total: 1546.99, estado: 'pagada' },
        { id: 3, factura: 'FAC-20241028-00003', pedido: 3, fecha: '2024-10-28', subtotal: 189.98, impuestos: 36.10, descuento: 0.00, total: 226.08, estado: 'pagada' },
        { id: 4, factura: 'FAC-20241030-00005', pedido: 5, fecha: '2024-10-30', subtotal: 150.00, impuestos: 28.50, descuento: 10.00, total: 168.50, estado: 'pagada' },
        { id: 5, factura: 'FAC-20241031-00006', pedido: 6, fecha: '2024-10-31', subtotal: 2599.98, impuestos: 494.00, descuento: 0.00, total: 3093.98, estado: 'pagada' },
        { id: 6, factura: 'FAC-20241101-00007', pedido: 7, fecha: '2024-11-01', subtotal: 89.99, impuestos: 17.10, descuento: 0.00, total: 107.09, estado: 'pagada' },
        { id: 7, factura: 'FAC-20241102-00008', pedido: 8, fecha: '2024-11-02', subtotal: 1299.99, impuestos: 247.00, descuento: 50.00, total: 1496.99, estado: 'pagada' },
        { id: 8, factura: 'FAC-20241103-00009', pedido: 9, fecha: '2024-11-03', subtotal: 450.00, impuestos: 85.50, descuento: 0.00, total: 535.50, estado: 'pagada' },
        { id: 9, factura: 'FAC-20241104-00011', pedido: 11, fecha: '2024-11-04', subtotal: 171.00, impuestos: 32.49, descuento: 0.00, total: 203.49, estado: 'pagada' },
        { id: 10, factura: 'FAC-20241104-00012', pedido: 12, fecha: '2024-11-04', subtotal: 150.00, impuestos: 28.50, descuento: 15.00, total: 163.50, estado: 'pagada' }
    ],
    clientes: [
        { id: 1, nombre: 'Juan Pérez', email: 'juan.perez@email.com', telefono: '3001234567', estado: 'activo', registro: '2024-09-15' },
        { id: 2, nombre: 'María Gómez', email: 'maria.gomez@email.com', telefono: '3109876543', estado: 'activo', registro: '2024-09-20' },
        { id: 3, nombre: 'Carlos Rodríguez', email: 'carlos.rod@email.com', telefono: '3151112233', estado: 'activo', registro: '2024-09-25' },
        { id: 4, nombre: 'Ana Martínez', email: 'ana.martinez@email.com', telefono: '3204445566', estado: 'inactivo', registro: '2024-10-01' },
        { id: 5, nombre: 'Luis Fernández', email: 'luis.fernandez@email.com', telefono: '3007778899', estado: 'activo', registro: '2024-10-05' },
        { id: 6, nombre: 'Sofía López', email: 'sofia.lopez@email.com', telefono: '3112223344', estado: 'activo', registro: '2024-10-10' },
        { id: 7, nombre: 'Diego Ramírez', email: 'diego.ramirez@email.com', telefono: '3165556677', estado: 'activo', registro: '2024-10-15' },
        { id: 8, nombre: 'Valentina Torres', email: 'valentina.torres@email.com', telefono: '3188889900', estado: 'activo', registro: '2024-10-20' },
        { id: 9, nombre: 'Andrés Flores', email: 'andres.flores@email.com', telefono: '3001110000', estado: 'activo', registro: '2024-10-25' },
        { id: 10, nombre: 'Camila Vargas', email: 'camila.vargas@email.com', telefono: '3123334455', estado: 'activo', registro: '2024-10-30' }
    ]
};

// ==========================================
// UTILIDADES
// ==========================================

const formatCurrency = (value) => {
    return new Intl.NumberFormat('es-CO', {
        style: 'currency',
        currency: 'USD',
        minimumFractionDigits: 2
    }).format(value);
};

const formatDate = (dateStr) => {
    return new Date(dateStr).toLocaleDateString('es-CO', {
        year: 'numeric',
        month: 'short',
        day: 'numeric'
    });
};

// ==========================================
// NAVEGACIÓN
// ==========================================

const navItems = document.querySelectorAll('.nav-item');
const sections = document.querySelectorAll('.section');
const pageTitle = document.getElementById('pageTitle');
const pageSubtitle = document.getElementById('pageSubtitle');

const sectionTitles = {
    dashboard: { title: 'Dashboard', subtitle: 'Resumen general de TiendaBeta' },
    productos: { title: 'Productos', subtitle: 'Gestión del catálogo de productos' },
    pedidos: { title: 'Pedidos', subtitle: 'Seguimiento de pedidos de clientes' },
    ventas: { title: 'Ventas', subtitle: 'Registro de ventas y facturación' },
    clientes: { title: 'Clientes', subtitle: 'Base de datos de clientes' },
    inventario: { title: 'Inventario', subtitle: 'Control de stock y almacén' },
    reportes: { title: 'Reportes', subtitle: 'Generación de reportes y exportaciones' },
    configuracion: { title: 'Configuración', subtitle: 'Ajustes del sistema' }
};

navItems.forEach(item => {
    item.addEventListener('click', (e) => {
        e.preventDefault();
        const section = item.dataset.section;
        
        // Actualizar nav activo
        navItems.forEach(n => n.classList.remove('active'));
        item.classList.add('active');
        
        // Mostrar sección
        sections.forEach(s => s.classList.remove('active'));
        document.getElementById(`section-${section}`).classList.add('active');
        
        // Actualizar título
        if (sectionTitles[section]) {
            pageTitle.textContent = sectionTitles[section].title;
            pageSubtitle.textContent = sectionTitles[section].subtitle;
        }
    });
});

// ==========================================
// SIDEBAR TOGGLE (Mobile)
// ==========================================

const sidebarToggle = document.getElementById('sidebarToggle');
const sidebar = document.querySelector('.sidebar');

sidebarToggle?.addEventListener('click', () => {
    sidebar.classList.toggle('open');
});

// ==========================================
// THEME TOGGLE
// ==========================================

const themeToggle = document.getElementById('themeToggle');
const themeIcon = themeToggle?.querySelector('i');

themeToggle?.addEventListener('click', () => {
    const currentTheme = document.documentElement.getAttribute('data-theme');
    const newTheme = currentTheme === 'light' ? 'dark' : 'light';
    document.documentElement.setAttribute('data-theme', newTheme);
    themeIcon.className = newTheme === 'light' ? 'fas fa-sun' : 'fas fa-moon';
    localStorage.setItem('theme', newTheme);
});

// Cargar tema guardado
const savedTheme = localStorage.getItem('theme') || 'dark';
document.documentElement.setAttribute('data-theme', savedTheme);
if (themeIcon) {
    themeIcon.className = savedTheme === 'light' ? 'fas fa-sun' : 'fas fa-moon';
}

// ==========================================
// RENDER KPIs
// ==========================================

function renderKPIs() {
    const totalVentas = mockData.ventas.reduce((sum, v) => sum + v.total, 0);
    const totalPedidos = mockData.pedidos.length;
    const totalProductos = mockData.productos.length;
    const totalClientes = mockData.clientes.length;

    document.getElementById('kpi-ventas').textContent = formatCurrency(totalVentas);
    document.getElementById('kpi-pedidos').textContent = totalPedidos;
    document.getElementById('kpi-productos').textContent = totalProductos;
    document.getElementById('kpi-clientes').textContent = totalClientes;

    // Badges
    document.getElementById('badge-productos').textContent = totalProductos;
    document.getElementById('badge-pedidos').textContent = totalPedidos;
}

// ==========================================
// RENDER PRODUCTOS TABLE
// ==========================================

function renderProductos() {
    const tbody = document.getElementById('tbodyProductos');
    tbody.innerHTML = mockData.productos.map(p => `
        <tr>
            <td><code>${p.sku}</code></td>
            <td><strong>${p.nombre}</strong></td>
            <td>${p.categoria}</td>
            <td>${formatCurrency(p.precio)}</td>
            <td>
                <div class="stock-indicator">
                    ${p.stock} / ${p.stock_min} min
                </div>
            </td>
            <td><span class="status-badge ${p.estado}">${p.estado}</span></td>
            <td>
                <div class="action-btns">
                    <button class="action-btn" title="Ver"><i class="fas fa-eye"></i></button>
                    <button class="action-btn" title="Editar"><i class="fas fa-edit"></i></button>
                    <button class="action-btn danger" title="Eliminar"><i class="fas fa-trash"></i></button>
                </div>
            </td>
        </tr>
    `).join('');
}

// ==========================================
// RENDER PEDIDOS TABLE
// ==========================================

function renderPedidos() {
    const tbody = document.getElementById('tbodyPedidos');
    tbody.innerHTML = mockData.pedidos.map(p => `
        <tr>
            <td><strong>#${p.id}</strong></td>
            <td>${p.cliente}</td>
            <td>${formatDate(p.fecha)}</td>
            <td>${formatCurrency(p.total)}</td>
            <td><span class="status-badge ${p.estado}">${p.estado}</span></td>
            <td>
                <div class="action-btns">
                    <button class="action-btn" title="Ver detalles"><i class="fas fa-eye"></i></button>
                    <button class="action-btn" title="Editar"><i class="fas fa-edit"></i></button>
                </div>
            </td>
        </tr>
    `).join('');
}

// ==========================================
// RENDER VENTAS TABLE
// ==========================================

function renderVentas() {
    const tbody = document.getElementById('tbodyVentas');
    tbody.innerHTML = mockData.ventas.map(v => `
        <tr>
            <td><code>${v.factura}</code></td>
            <td>#${v.pedido}</td>
            <td>${formatDate(v.fecha)}</td>
            <td>${formatCurrency(v.subtotal)}</td>
            <td>${formatCurrency(v.impuestos)}</td>
            <td><strong>${formatCurrency(v.total)}</strong></td>
            <td><span class="status-badge ${v.estado}">${v.estado}</span></td>
        </tr>
    `).join('');

    // KPIs de ventas
    const totalMes = mockData.ventas.reduce((sum, v) => sum + v.total, 0);
    const totalImpuestos = mockData.ventas.reduce((sum, v) => sum + v.impuestos, 0);
    document.getElementById('ventas-mes').textContent = formatCurrency(totalMes);
    document.getElementById('facturas-mes').textContent = mockData.ventas.length;
    document.getElementById('impuestos-mes').textContent = formatCurrency(totalImpuestos);
}

// ==========================================
// RENDER CLIENTES TABLE
// ==========================================

function renderClientes() {
    const tbody = document.getElementById('tbodyClientes');
    tbody.innerHTML = mockData.clientes.map(c => `
        <tr>
            <td>${c.id}</td>
            <td><strong>${c.nombre}</strong></td>
            <td>${c.email}</td>
            <td>${c.telefono}</td>
            <td><span class="status-badge ${c.estado}">${c.estado}</span></td>
            <td>${formatDate(c.registro)}</td>
        </tr>
    `).join('');
}

// ==========================================
// RENDER INVENTARIO
// ==========================================

function renderInventario() {
    const grid = document.getElementById('inventoryGrid');
    grid.innerHTML = mockData.productos.map(p => {
        const stockPercent = Math.min((p.stock / p.stock_min) * 100, 100);
        const stockClass = p.stock <= p.stock_min ? 'stock-low' : 
                          p.stock <= p.stock_min * 2 ? 'stock-medium' : 'stock-high';
        
        return `
            <div class="inventory-card">
                <div class="inventory-header">
                    <div>
                        <strong>${p.nombre}</strong>
                        <div class="inventory-sku">${p.sku}</div>
                    </div>
                    <span class="status-badge ${p.estado}">${p.estado}</span>
                </div>
                <div style="margin: 15px 0;">
                    <div style="display: flex; justify-content: space-between; font-size: 0.85rem; margin-bottom: 5px;">
                        <span>Stock: ${p.stock}</span>
                        <span>Mín: ${p.stock_min}</span>
                    </div>
                    <div class="inventory-stock-bar">
                        <div class="inventory-stock-fill ${stockClass}" style="width: ${stockPercent}%"></div>
                    </div>
                </div>
                <div style="display: flex; justify-content: space-between; align-items: center;">
                    <span style="font-size: 1.2rem; font-weight: 700;">${formatCurrency(p.precio)}</span>
                    <span style="font-size: 0.85rem; color: var(--text-muted);">${p.categoria}</span>
                </div>
            </div>
        `;
    }).join('');
}

// ==========================================
// RENDER ACTIVITIES
// ==========================================

function renderRecentOrders() {
    const container = document.getElementById('recentOrders');
    const recent = mockData.pedidos.slice(0, 5);
    container.innerHTML = recent.map(p => `
        <div class="activity-item">
            <div class="activity-info">
                <span class="activity-title">Pedido #${p.id}</span>
                <span class="activity-subtitle">${p.cliente} · ${formatDate(p.fecha)}</span>
            </div>
            <div style="text-align: right;">
                <div class="activity-value">${formatCurrency(p.total)}</div>
                <span class="status-badge ${p.estado}" style="font-size: 0.7rem;">${p.estado}</span>
            </div>
        </div>
    `).join('');
}

function renderStockAlerts() {
    const container = document.getElementById('stockAlerts');
    const lowStock = mockData.productos.filter(p => p.stock <= p.stock_min);
    
    if (lowStock.length === 0) {
        container.innerHTML = '<div class="activity-item"><span style="color: var(--text-muted);">No hay alertas de stock</span></div>';
        return;
    }
    
    container.innerHTML = lowStock.map(p => `
        <div class="activity-item">
            <div class="activity-info">
                <span class="activity-title">${p.nombre}</span>
                <span class="activity-subtitle">SKU: ${p.sku}</span>
            </div>
            <div style="text-align: right;">
                <div class="activity-value" style="color: var(--danger);">${p.stock} unid.</div>
                <span style="font-size: 0.75rem; color: var(--text-muted);">Mín: ${p.stock_min}</span>
            </div>
        </div>
    `).join('');
}

// ==========================================
// CHARTS (Chart.js)
// ==========================================

let ventasChart, pedidosChart;

function initCharts() {
    const chartColors = {
        primary: '#6366f1',
        secondary: '#8b5cf6',
        success: '#10b981',
        warning: '#f59e0b',
        danger: '#ef4444',
        info: '#3b82f6'
    };

    // Gráfico de Ventas por Categoría
    const categorias = {};
    mockData.productos.forEach(p => {
        categorias[p.categoria] = (categorias[p.categoria] || 0) + p.precio;
    });

    const ventasCtx = document.getElementById('ventasChart')?.getContext('2d');
    if (ventasCtx) {
        ventasChart = new Chart(ventasCtx, {
            type: 'bar',
            data: {
                labels: Object.keys(categorias),
                datasets: [{
                    label: 'Ventas por Categoría',
                    data: Object.values(categorias),
                    backgroundColor: [
                        chartColors.primary,
                        chartColors.secondary,
                        chartColors.success,
                        chartColors.warning,
                        chartColors.info,
                        chartColors.danger
                    ],
                    borderRadius: 8
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: { color: 'rgba(148, 163, 184, 0.1)' },
                        ticks: { color: '#94a3b8' }
                    },
                    x: {
                        grid: { display: false },
                        ticks: { color: '#94a3b8' }
                    }
                }
            }
        });
    }

    // Gráfico de Estado de Pedidos
    const estados = {};
    mockData.pedidos.forEach(p => {
        estados[p.estado] = (estados[p.estado] || 0) + 1;
    });

    const pedidosCtx = document.getElementById('pedidosChart')?.getContext('2d');
    if (pedidosCtx) {
        pedidosChart = new Chart(pedidosCtx, {
            type: 'doughnut',
            data: {
                labels: Object.keys(estados),
                datasets: [{
                    data: Object.values(estados),
                    backgroundColor: [
                        chartColors.warning,
                        chartColors.info,
                        chartColors.primary,
                        chartColors.success,
                        chartColors.danger
                    ],
                    borderWidth: 0
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: { color: '#94a3b8', padding: 15 }
                    }
                }
            }
        });
    }
}

// ==========================================
// REFRESH BUTTON
// ==========================================

const refreshBtn = document.getElementById('refreshBtn');
refreshBtn?.addEventListener('click', () => {
    refreshBtn.querySelector('i').classList.add('fa-spin');
    setTimeout(() => {
        refreshBtn.querySelector('i').classList.remove('fa-spin');
        renderAll();
    }, 1000);
});

// ==========================================
// GLOBAL SEARCH
// ==========================================

const globalSearch = document.getElementById('globalSearch');
globalSearch?.addEventListener('input', (e) => {
    const query = e.target.value.toLowerCase();
    if (query.length < 2) return;
    
    // Buscar en productos
    const found = mockData.productos.filter(p => 
        p.nombre.toLowerCase().includes(query) || 
        p.sku.toLowerCase().includes(query)
    );
    
    if (found.length > 0) {
        // Navegar a productos y filtrar
        document.querySelector('[data-section="productos"]').click();
        // Aquí podrías implementar filtrado en tiempo real
    }
});

// ==========================================
// MODAL
// ==========================================

const modal = document.getElementById('detailModal');
const modalClose = document.getElementById('modalClose');

modalClose?.addEventListener('click', () => {
    modal.classList.remove('active');
});

modal?.addEventListener('click', (e) => {
    if (e.target === modal) {
        modal.classList.remove('active');
    }
});

// ==========================================
// RENDER ALL
// ==========================================

function renderAll() {
    renderKPIs();
    renderProductos();
    renderPedidos();
    renderVentas();
    renderClientes();
    renderInventario();
    renderRecentOrders();
    renderStockAlerts();
}

// ==========================================
// INIT
// ==========================================

document.addEventListener('DOMContentLoaded', () => {
    renderAll();
    initCharts();
    console.log('🚀 TiendaBeta Dashboard initialized');
    console.log('📦 Productos:', mockData.productos.length);
    console.log('🛒 Pedidos:', mockData.pedidos.length);
    console.log(' Ventas:', mockData.ventas.length);
    console.log('👥 Clientes:', mockData.clientes.length);
});