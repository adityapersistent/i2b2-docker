#docker-compose up -d i2b2-data-pgsql i2b2-core-server i2b2-webclient
# echo "waiting for database docker container to get start"
#sleep 180

echo "Dump process started"
docker exec -i -e PG_PASSWORD=demouser i2b2-data-pgsql pg_dumpall -U postgres -f i2b2_global.sql

#local dump, local psql
#docker exec -i -e PG_PASSWORD=demouser i2b2-data-pgsql pg_dumpall -U postgres  > i2b2_global.sql
#dump - 1min approx.
echo "Dump process done"


#install postgresql database locally and update the configuration 
#bash install_postgresql.sh

host=$1
port=$2
username=$3
password=$4
echo "Host- $host Port- $port Username-$username Password-$password"

#for remote database 
echo "Restore process started"
docker exec -i -e PGPASSWORD=$password i2b2-data-pgsql psql -h $host -p $port -U $username  -f i2b2_global.sql

#for local database using docker container
# docker exec -i -e PG_PASSWORD=demouser i2b2-data-pgsql psql -U postgres -f i2b2_global.sql


#psql -U postgres -f i2b2_global.sql #
echo "Restore process completed"
#within 2 minutes


default_host="i2b2-data-pgsql"
default_port="5432"
default_username="i2b2"
default_password="demouser"

#update the ip in .env file
#get the ip addr docker inspect network i2b2-net

sed -i "s/${default_host}/${host}/g" .env
sed -i "s/${default_port}/${port}/g" .env
sed -i "s/${default_username}/${username}/g" .env
sed -i "s/${default_password}/${password}/g" .env


# docker rm -f i2b2-data-pgsql

docker compose down
sleep 50
docker compose up -d i2b2-core-server i2b2-webclient




