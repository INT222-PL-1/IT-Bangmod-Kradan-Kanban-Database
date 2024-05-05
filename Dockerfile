FROM mysql/mysql-server:latest
#COPY ./my.cnf /etc/
VOLUME ./mysql-datalib /var/lib/mysql
COPY ./dbscript.sql /docker-entrypoint-initdb.d/
ENV MYSQL_ROOT_PASSWORD=itb-kk
EXPOSE 3306
