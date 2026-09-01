FROM mysql:8.4

# Configurar InnoDB como motor por defecto y optimizaciones básicas
RUN echo "[mysqld]" > /etc/mysql/conf.d/innodb.cnf && \
    echo "default-storage-engine=INNODB" >> /etc/mysql/conf.d/innodb.cnf && \
    echo "innodb_file_per_table=1" >> /etc/mysql/conf.d/innodb.cnf && \
    echo "innodb_buffer_pool_size=256M" >> /etc/mysql/conf.d/innodb.cnf && \
    echo "innodb_log_file_size=64M" >> /etc/mysql/conf.d/innodb.cnf && \
    echo "innodb_flush_log_at_trx_commit=2" >> /etc/mysql/conf.d/innodb.cnf && \
    echo "innodb_flush_method=O_DIRECT" >> /etc/mysql/conf.d/innodb.cnf

EXPOSE 3306