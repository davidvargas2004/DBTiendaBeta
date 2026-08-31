🗄️ TiendaBeta - Sistema de Bases de Datos Distribuidas
Arquitectura de microservicios de datos usando PostgreSQL, MySQL y MongoDB en contenedores Docker, donde cada motor cumple un rol estratégico según sus fortalezas.
📖 Descripción
Este proyecto implementa un sistema de bases de datos distribuidas para la plataforma TiendaBeta, aprovechando las capacidades únicas de tres motores de bases de datos. Cada contenedor está especializado en un tipo de carga de trabajo específica, siguiendo el principio de "usar la herramienta correcta para el trabajo correcto".
🏗️ Arquitectura

┌─────────────────────────────────────────────────────────────┐
│                    TiendaBeta - App Layer                    │
──────────────┬────────────────────────────────────────────┘
               │                    │                    │
               ▼                    ▼                    ▼
        ┌─────────────┐    ┌──────────────┐    ┌──────────────┐
        │ PostgreSQL  │    │   MongoDB    │    │    MySQL     │
        │ (El Auditor)│    │(El Flexible) │    │(El Velocista)│
        │             │    │              │    │              │
        │• Ventas     │    │• Logs        │    │• Catálogo    │
        │• Pagos      │    │• Reseñas     │    │• Inventario  │
        │• JSONB      │    │• Actividad   │    │• Lecturas    │
        └─────────────┘    └──────────────┘    ──────────────┘
              :5432                :27017               :3306


 Rol de cada Base de Datos
🐘 PostgreSQL — El Auditor
Característica
Detalle
Superpoder
Integridad absoluta y tipos de datos avanzados (JSONB)
Misión en TiendaBeta
Transacciones críticas: Ventas y Pagos
Por qué
ACID estricto, constraints, foreign keys, soporte para datos financieros
🍃 MongoDB — El Flexible
Característica
Detalle
Superpoder
Estructura variable y altísima velocidad de escritura
Misión en TiendaBeta
Logs de actividad y reseñas dinámicas de productos
Por qué
Schema-less, escritura rápida, ideal para datos no estructurados o semiestructurados
🐬 MySQL — El Velocista
Característica
Detalle
Superpoder
Lecturas ultrarrápidas y adopción universal
Misión en TiendaBeta
Consultas de catálogo e inventario
Por qué
Optimizado para lecturas masivas, índices eficientes, ampliamente soportado
️ Tecnologías
🐳 Docker & Docker Compose
🐘 PostgreSQL 16
🍃 MongoDB 7
🐬 MySQL 8
🐍 Python / Node.js (capa de aplicación - opcional)
📁 Estructura del Proyecto







tiendabeta-distributed-db/
├── docker-compose.yml          # Orquestación de contenedores
├── .env                        # Variables de entorno
├── postgres/
│   ├── Dockerfile
│   ├── init.sql                # Scripts de inicialización
│   └── data/                   # Volumen persistente
├── mysql/
│   ├── Dockerfile
│   ├── init.sql
│   └── data/
├── mongodb/
│   ├── Dockerfile
│   ├── init.js
│   └── data/
├── app/                        # Capa de aplicación (opcional)
│   └── ...
└── README.md






⚙️ Requisitos Previos
Docker instalado
Docker Compose (v2.0+)
4 GB de RAM disponibles (mínimo recomendado)
