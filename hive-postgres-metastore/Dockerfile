FROM postgres:11.7
LABEL maintainer="Oliver Tosky" \
      maintainer-email="olivertosky@gmail.com"

COPY hive-schema-2.3.0.postgres.sql /tmp/
COPY hive-txn-schema-2.3.0.postgres.sql /tmp/

COPY init-hive-db.sh /docker-entrypoint-initdb.d/init-user-db.sh