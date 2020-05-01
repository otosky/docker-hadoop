FROM postgres:11.7

MAINTAINER "Ivan Ermilov <ivan.s.ermilov@gmail.com>"

COPY hive-schema-2.3.0.postgres.sql /tmp/
COPY hive-txn-schema-2.3.0.postgres.sql /tmp/

COPY init-hive-db.sh /docker-entrypoint-initdb.d/init-user-db.sh