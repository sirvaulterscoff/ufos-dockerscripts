from postgres:9

COPY create.sql /tmp/create.sql
COPY init_db.sh /docker-entrypoint-initdb.d/

ENV POSTGRES_PASSWORD Oracle33
ENV POSTGRES_USER ufos
ENV POSTGRES_DB ufos



#RUN gosu postgres postgres && pg_restore /tmp/db_dump
#RUN /docker-entrypoint.sh postgres && pg_restore --verbose  /tmp/db_dump

CMD ["postgres"]
