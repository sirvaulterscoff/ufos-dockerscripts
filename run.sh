echo "#cheking data-cotainer"
dbcont=`docker ps -a -f name=dbstore | wc -l`
[ $dbcont -eq 1 ] && docker create -v /var/lib/postgresql/data --name dbstore postgres /bin/true

echo "#checking postgre"
db=`docker ps -a -f name=db | wc -l`
[ $db -eq 1 ] && docker run -d --volumes-from dbstore -p 4321:4321 --name db otr/ufos-db

echo "#running ufos"
docker run --rm --name ufos --link db:db -p 18080:18080 otr/rshn-func

