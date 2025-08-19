# sh backup_restore_mssql.sh dummy_host 1432 SA '<YourStrong@Passw0rd>' i2b2demodata i2b2metadata i2b2pm i2b2hive i2b2workdata

# docker rm -f $(docker ps -a -q) #cleaning exising docker containers
docker compose up -d 

# we are restoring the database to a new docker mssql database container hence we are providing the docker network ip as a remote host ip
docker_network_gateway_ip=$(docker network inspect i2b2-net -f '{{range .IPAM.Config}}{{.Gateway}}{{end}}') 

host=$1
host=$docker_network_gateway_ip
port=$2
username=$3
password=$4

export crc_dbname=$5
export ont_dbname=$6
export pm_dbname=$7
export hive_dbname=$8
export wd_dbname=$9

echo "Host- $host Port- $port Username- $username Password- $password "
echo "waiting for database docker container to get start"

docker run -i -e "ACCEPT_EULA=Y"  -e "SA_PASSWORD=<YourStrong@Passw0rd>"  -p 1432:1433 --net i2b2-net -v i2b2-mssql-vol-gen:/var/opt/mssql --name i2b2-mssql -d mcr.microsoft.com/mssql/server:2017-latest

sleep 180 
docker exec -i i2b2-data-mssql /opt/mssql-tools/bin/sqlcmd -S localhost,1433 -U sa -P '<YourStrong@Passw0rd>' -Q "backup database i2b2demodata to DISK =  N'/tmp/i2b2demodata.bak' WITH INIT , COMPRESSION;"

docker exec -i i2b2-data-mssql /opt/mssql-tools/bin/sqlcmd -S localhost,1433 -U sa -P '<YourStrong@Passw0rd>' -Q "backup database i2b2metadata to DISK =  N'/tmp/i2b2metadata.bak' WITH INIT , COMPRESSION;"

docker exec -i i2b2-data-mssql /opt/mssql-tools/bin/sqlcmd -S localhost,1433 -U sa -P '<YourStrong@Passw0rd>' -Q "backup database i2b2pm to DISK =  N'/tmp/i2b2pm.bak' WITH INIT , COMPRESSION;"

docker exec -i i2b2-data-mssql /opt/mssql-tools/bin/sqlcmd -S localhost,1433 -U sa -P '<YourStrong@Passw0rd>' -Q "backup database i2b2hive to DISK =  N'/tmp/i2b2hive.bak' WITH INIT , COMPRESSION;"

docker exec -i i2b2-data-mssql /opt/mssql-tools/bin/sqlcmd -S localhost,1433 -U sa -P '<YourStrong@Passw0rd>' -Q "backup database i2b2workdata to DISK =  N'/tmp/i2b2workdata.bak' WITH INIT , COMPRESSION;"

echo "Backup Completed"
sleep 10
docker exec -e crc_dbname -i i2b2-data-mssql /opt/mssql-tools/bin/sqlcmd -S $ip,$port -U $username -P $password -Q  "Restore database $crc_dbname from disk = N'i2b2demodata.bak' with replace, move 'i2b2demodata' to '/var/opt/mssql/data/$crc_dbname.mdf', move 'i2b2demodata_log' to '/var/opt/mssql/data/$crc_dbname_log.ldf'"

docker exec -e ont_dbname -i i2b2-data-mssql /opt/mssql-tools/bin/sqlcmd -S $ip,$port -U $username -P $password -Q  "Restore database $ont_dbname from disk = N'i2b2metadata.bak' with replace, move 'i2b2metadata' to '/var/opt/mssql/data/$ont_dbname.mdf', move 'i2b2metadata_log' to '/var/opt/mssql/data/$ont_dbname_log.ldf'"

docker exec -e $pm_dbname -i i2b2-data-mssql /opt/mssql-tools/bin/sqlcmd -S $ip,$port -U $username -P $password -Q  "Restore database $pm_dbname from disk = N'i2b2pm.bak' with replace, move 'i2b2pm' to '/var/opt/mssql/data/$pm_dbname.mdf', move 'i2b2pm_log' to '/var/opt/mssql/data/$pm_dbname_log.ldf'"

docker exec -e $hive_dbname -i i2b2-data-mssql /opt/mssql-tools/bin/sqlcmd -S $ip,$port -U $username -P $password -Q  "Restore database $hive_dbname from disk = N'i2b2hive.bak' with replace, move 'i2b2hive' to '/var/opt/mssql/data/$hive_dbname.mdf', move 'i2b2hive_log' to '/var/opt/mssql/data/$hive_dbname_log.ldf'"

docker exec -e $wd_dbname-i i2b2-data-mssql /opt/mssql-tools/bin/sqlcmd -S $ip,$port -U $username -P $password -Q  "Restore database $wd_dbname from disk = N'i2b2workdata.bak' with replace, move 'i2b2workdata' to '/var/opt/mssql/data/$wd_dbname.mdf', move 'i2b2workdata_log' to '/var/opt/mssql/data/$wd_dbname_log.ldf'"


echo "Restore Completed"
sleep 10

default_host="_IP=i2b2-data-mssql"
default_port="_PORT=1433"
default_username="_USER=i2b2"
default_password="_PASS=demouser"

default_crc_dbname="_CRC_DB=i2b2demodata"
default_ont_db_name="_ONT_DB=i2b2metadata"
default_pm_db_name="_PM_DB=i2b2pm"
default_hive_dbname="_HIVE_DB=i2b2hive"
default_wd_dbname="_WD_DB=i2b2workdata"


#updating the .env file
echo "Updating .env file"
sed -i "s/${default_host}/_IP=${host}/g" .env
sed -i "s/${default_port}/_PORT=${port}/g" .env
sed -i "s/${default_username}/_USER=${username}/g" .env
sed -i "s/${default_password}/_PASS=${password}/g" .env

sed -i "s/${default_crc_dbname}/_CRC_DB=${crc_dbname}/g" .env
sed -i "s/${default_ont_db_name}/_ONT_DB=${ont_dbname}/g" .env
sed -i "s/${default_pm_db_name}/_PM_DB=${pm_dbname}/g" .env
sed -i "s/${default_hive_dbname}/_HIVE_DB=${hive_dbname}/g" .env
sed -i "s/${default_wd_dbname}/_WD_DB=${wd_dbname}/g" .env


# docker rm -f i2b2-data-mssql #uncomment this line if you have space issue

docker compose down
docker compose up -d i2b2-core-server i2b2-webclient

echo "Started i2b2-core-server & i2b2-webclient Docker containers"
echo "logs of i2b2-core-server container - "
docker logs -f i2b2-core-server




