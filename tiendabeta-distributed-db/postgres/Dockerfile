# Usar la versión 16 de PostgreSQL (Alpine es más ligera y segura)
FROM postgres:16-alpine

# Instalar herramientas adicionales de PostgreSQL (necesario para extensiones como uuid-ossp, pg_stat_statements, etc.)
RUN apk add --no-cache postgresql-contrib

# Optimizaciones de rendimiento para PostgreSQL
# Estas configuraciones benefician especialmente el uso de JSONB e índices GIN
RUN echo "max_connections = 200" >> /usr/share/postgresql/postgresql.conf.sample && \
    echo "shared_buffers = 256MB" >> /usr/share/postgresql/postgresql.conf.sample && \
    echo "effective_cache_size = 1GB" >> /usr/share/postgresql/postgresql.conf.sample && \
    echo "maintenance_work_mem = 64MB" >> /usr/share/postgresql/postgresql.conf.sample && \
    echo "checkpoint_completion_target = 0.9" >> /usr/share/postgresql/postgresql.conf.sample && \
    echo "wal_buffers = 16MB" >> /usr/share/postgresql/postgresql.conf.sample && \
    echo "default_statistics_target = 100" >> /usr/share/postgresql/postgresql.conf.sample && \
    echo "random_page_cost = 1.1" >> /usr/share/postgresql/postgresql.conf.sample && \
    echo "effective_io_concurrency = 200" >> /usr/share/postgresql/postgresql.conf.sample && \
    echo "work_mem = 4MB" >> /usr/share/postgresql/postgresql.conf.sample

# Exponer el puerto por defecto de PostgreSQL
EXPOSE 5432