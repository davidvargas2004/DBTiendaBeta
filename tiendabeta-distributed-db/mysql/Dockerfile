FROM mysql:8.4

# Configurar InnoDB como motor por defecto
COPY <<EOF /etc/mysql/conf.d/innodb.cnf
[mysqld]
default-storage-engine=INNODB
innodb_file_per_table=1
innodb_buffer_pool_size=256M
innodb_log_file_size=64M
innodb_flush_log_at_trx_commit=2
innodb_flush_method=O_DIRECT
EOF

EXPOSE 3306