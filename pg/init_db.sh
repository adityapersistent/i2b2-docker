#sh init_db.sh dummy_host 5432 i2b2 demouser i2b2

host=$1
port=$2
username=$3
password=$4
dbname=$5

echo "Host- $host Port- $port Username- $username Password- $password DBname- $dbname"
echo "waiting for database docker container to get start"
if [ "$host" = "dummy_host" ]; then
  
    docker_network_gateway_ip=$(docker network inspect i2b2-net -f '{{range .IPAM.Config}}{{.Gateway}}{{end}}') 
    host=$docker_network_gateway_ip
    sh create_native_pg_server.sh #install native postgresql database locally and update the configuration 
fi
sleep 180

echo "Dump process started"

docker exec -i -e PG_PASSWORD=demouser i2b2-data-pgsql pg_dump -U postgres -d i2b2 -F c --no-owner --no-acl -f i2b2_db_backup.dump
#dump - 1min approx.
echo "Dump process completed"
echo "restore process started"

echo $host $port $username $dbname $password
docker exec -i -e PGPASSWORD=$password i2b2-data-pgsql pg_restore  -h $host -p $port -U $username -d $dbname  -F c --no-owner i2b2_db_backup.dump

echo "Restore process completed"
#within 2 minutes

echo "Completed backup and restore for all the databases."
echo "Run the mod_env_file script for updating environment variables."

