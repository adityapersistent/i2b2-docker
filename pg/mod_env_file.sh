# sh mod_env_file.sh dummy_host 5432 i2b2 demouser i2b2
target_host=$1
target_port=$2
target_username=$3
target_password=$4
target_dbname=$5

default_host="_IP=i2b2-data-pgsql"
default_port="_PORT=5432"
default_username="_USER=i2b2"
default_password="_PASS=demouser"
default_dbname="_DB=i2b2"

if [ $target_host = "dummy_host" ]; then

    docker_network_gateway_ip=$(docker network inspect i2b2-net -f '{{range .IPAM.Config}}{{.Gateway}}{{end}}')
    target_host=$docker_network_gateway_ip
    echo "Target Server IP- " $target_host 
fi  

#updating the .env file

sed -i "s/${default_host}/_IP=${target_host}/g" .env
sed -i "s/${default_port}/_PORT=${target_port}/g" .env
sed -i "s/${default_username}/_USER=${target_username}/g" .env #single user for all databases
sed -i "s/${default_password}/_PASS=${target_password}/g" .env
sed -i "s/${default_dbname}/_DB=${target_dbname}/g" .env

echo "Run the restart_containers script for updating docker configuration."