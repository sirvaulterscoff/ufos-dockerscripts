from postgres:9

COPY db_dump /tmp/db_dump
COPY pgup.sh /tmp/

ENV POSTGRES_PASSWORD Oracle33
ENV POSTGRES_USER ufos
ENV POSTGRES_DB ufos

#RUN chmod 0777 /tmp/pgup.sh
#RUN /tmp/pgup.sh

#RUN gosu postgres postgres && pg_restore /tmp/db_dump
#RUN /docker-entrypoint.sh postgres && pg_restore --verbose  /tmp/db_dump

CMD ["postgres"]
