docker rm -f $(docker ps -a -q)
docker-compose up -d 

export SOURCE_SERVER="localhost"
export SOURCE_USER="sa"
export SOURCE_PASS="<YourStrong@Passw0rd>"
export SOURCE_CRC_DB="i2b2demodata"
export SOURCE_ONT_DB="i2b2metadata"
export SOURCE_PM_DB="i2b2pm"
export SOURCE_HIVE_DB="i2b2hive"
export SOURCE_WD_DB="i2b2workdata"

export TARGET_SERVER="dummy_host" #host,port
export TARGET_PORT="1432"
export TARGET_USER="sa"
export TARGET_PASS="<YourStrong@Passw0rd>"
export TARGET_CRC_DB="i2b2demodata"
export TARGET_ONT_DB="i2b2metadata"
export TARGET_PM_DB="i2b2pm"
export TARGET_HIVE_DB="i2b2hive"
export TARGET_WD_DB="i2b2workdata"

if [ $TARGET_SERVER = "dummy_host" ]; then

    export docker_network_gateway_ip=$(docker network inspect i2b2-net -f '{{range .IPAM.Config}}{{.Gateway}}{{end}}')
    export TARGET_SERVER=$docker_network_gateway_ip,$TARGET_PORT
    echo $TARGET_SERVER 
    docker run -i -e "ACCEPT_EULA=Y"  -e "SA_PASSWORD=<YourStrong@Passw0rd>"  -p 1432:1433 --name target_db_container -d mcr.microsoft.com/mssql/server:2017-latest

fi 

sleep 120

docker exec -i i2b2-data-mssql /opt/sqlpackage/sqlpackage \
/Action:Export \
/SourceServerName:$SOURCE_SERVER \
/SourceDatabaseName:$SOURCE_CRC_DB \
/SourceUser:$SOURCE_USER \
/SourcePassword:$SOURCE_PASS  \
/TargetFile:$SOURCE_CRC_DB.bacpac


docker exec -i i2b2-data-mssql /opt/sqlpackage/sqlpackage \
/Action:Import \
/TargetServerName:$TARGET_SERVER \
/TargetDatabaseName:$TARGET_CRC_DB \
/TargetUser:$TARGET_USER \
/TargetPassword:$TARGET_PASS \
/SourceFile:$SOURCE_CRC_DB.bacpac \
/Diagnostics:true


docker exec -i i2b2-data-mssql /opt/sqlpackage/sqlpackage \
/Action:Export \
/SourceServerName:$SOURCE_SERVER \
/SourceDatabaseName:$SOURCE_ONT_DB \
/SourceUser:$SOURCE_USER \
/SourcePassword:$SOURCE_PASS  \
/TargetFile:$SOURCE_ONT_DB.bacpac


docker exec -i i2b2-data-mssql /opt/sqlpackage/sqlpackage \
/Action:Import \
/TargetServerName:$TARGET_SERVER \
/TargetDatabaseName:$TARGET_ONT_DB \
/TargetUser:$TARGET_USER \
/TargetPassword:$TARGET_PASS \
/SourceFile:$SOURCE_ONT_DB.bacpac \
/Diagnostics:true

docker exec -i i2b2-data-mssql /opt/sqlpackage/sqlpackage \
/Action:Export \
/SourceServerName:$SOURCE_SERVER \
/SourceDatabaseName:$SOURCE_PM_DB \
/SourceUser:$SOURCE_USER \
/SourcePassword:$SOURCE_PASS  \
/TargetFile:$SOURCE_PM_DB.bacpac

docker exec -i i2b2-data-mssql /opt/sqlpackage/sqlpackage \
/Action:Import \
/TargetServerName:$TARGET_SERVER \
/TargetDatabaseName:$TARGET_PM_DB \
/TargetUser:$TARGET_USER \
/TargetPassword:$TARGET_PASS \
/SourceFile:$SOURCE_PM_DB.bacpac \
/Diagnostics:true

docker exec -i i2b2-data-mssql /opt/sqlpackage/sqlpackage \
/Action:Export \
/SourceServerName:$SOURCE_SERVER \
/SourceDatabaseName:$SOURCE_HIVE_DB \
/SourceUser:$SOURCE_USER \
/SourcePassword:$SOURCE_PASS  \
/TargetFile:$SOURCE_HIVE_DB.bacpac

docker exec -i i2b2-data-mssql /opt/sqlpackage/sqlpackage \
/Action:Import \
/TargetServerName:$TARGET_SERVER \
/TargetDatabaseName:TARGET_HIVE_DB \
/TargetUser:$TARGET_USER \
/TargetPassword:$TARGET_PASS \
/SourceFile:$SOURCE_HIVE_DB.bacpac \
/Diagnostics:true

docker exec -i i2b2-data-mssql /opt/sqlpackage/sqlpackage \
/Action:Export \
/SourceServerName:$SOURCE_SERVER \
/SourceDatabaseName:$SOURCE_WD_DB \
/SourceUser:$SOURCE_USER \
/SourcePassword:$SOURCE_PASS  \
/TargetFile:$SOURCE_WD_DB.bacpac

docker exec -i i2b2-data-mssql /opt/sqlpackage/sqlpackage \
/Action:Import \
/TargetServerName:$TARGET_SERVER \
/TargetDatabaseName:TARGET_WD_DB \
/TargetUser:$TARGET_USER \
/TargetPassword:$TARGET_PASS \
/SourceFile:$SOURCE_WD_DB.bacpac \
/Diagnostics:true



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
sed -i "s/${default_host}/_IP=${docker_network_gateway_ip}/g" .env
sed -i "s/${default_port}/_PORT=${TARGET_PORT}/g" .env
sed -i "s/${default_username}/_USER=${TARGET_USER}/g" .env
sed -i "s/${default_password}/_PASS=${TARGET_PASS}/g" .env
 
sed -i "s/${default_crc_dbname}/_CRC_DB=${TARGET_CRC_DB}/g" .env
sed -i "s/${default_ont_db_name}/_ONT_DB=${TARGET_ONT_DB}/g" .env
sed -i "s/${default_pm_db_name}/_PM_DB=${TARGET_PM_DB}/g" .env
sed -i "s/${default_hive_dbname}/_HIVE_DB=${TARGET_HIVE_DB}/g" .env
sed -i "s/${default_wd_dbname}/_WD_DB=${TARGET_WD_DB}/g" .env
 
 
# docker rm -f i2b2-data-mssql #uncomment this line if you have space issue
 
docker rm -f i2b2-core-server i2b2-webclient
docker compose up -d i2b2-core-server i2b2-webclient
 
echo "Started i2b2-core-server & i2b2-webclient Docker containers"
echo "logs of i2b2-core-server container - "
docker logs -f i2b2-core-server