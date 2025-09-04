# sh init_db.sh dummy_host 1432 SA '<YourStrong@Passw0rd>' i2b2demodata i2b2metadata i2b2pm i2b2hive i2b2workdata i2b2-core-server 8080

export SOURCE_SERVER="localhost"
export SOURCE_USER="sa"
export SOURCE_PASS="<YourStrong@Passw0rd>"
export SOURCE_CRC_DB="i2b2demodata"
export SOURCE_ONT_DB="i2b2metadata"
export SOURCE_PM_DB="i2b2pm"
export SOURCE_HIVE_DB="i2b2hive"
export SOURCE_WD_DB="i2b2workdata"

export TARGET_SERVER=$1  #host,port
export TARGET_PORT=$2
export TARGET_USER=$3
export TARGET_PASS=$4
export TARGET_CRC_DB=$5
export TARGET_ONT_DB=$6
export TARGET_PM_DB=$7
export TARGET_HIVE_DB=$8
export TARGET_WD_DB=$9
export CORE_SERVER_IP=$10
export CORE_SERVER_PORT=$11

if [ $TARGET_SERVER = "dummy_host" ]; then

    export docker_network_gateway_ip=$(docker network inspect i2b2-net -f '{{range .IPAM.Config}}{{.Gateway}}{{end}}')
    export TARGET_SERVER=$docker_network_gateway_ip,$TARGET_PORT
    echo $TARGET_SERVER 
    docker run -i -e "ACCEPT_EULA=Y"  -e "SA_PASSWORD=<YourStrong@Passw0rd>"  -p 1432:1433 --name target_db_container -d mcr.microsoft.com/mssql/server:2017-latest

else
    export TARGET_SERVER=$TARGET_SERVER,$TARGET_PORT
fi 

sleep 180

docker exec -i i2b2-data-mssql /opt/sqlpackage/sqlpackage \
/Action:Export \
/SourceServerName:$SOURCE_SERVER \
/SourceDatabaseName:$SOURCE_CRC_DB \
/SourceUser:$SOURCE_USER \
/SourcePassword:$SOURCE_PASS  \
/TargetFile:$SOURCE_CRC_DB.bacpac
sleep 15

docker exec -i i2b2-data-mssql /opt/sqlpackage/sqlpackage \
/Action:Import \
/TargetServerName:$TARGET_SERVER \
/TargetDatabaseName:$TARGET_CRC_DB \
/TargetUser:$TARGET_USER \
/TargetPassword:$TARGET_PASS \
/SourceFile:$SOURCE_CRC_DB.bacpac  
echo "completed CRC db restore"
sleep 20

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
/SourceFile:$SOURCE_ONT_DB.bacpac  
echo "completed ONT db restore"
sleep 20

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
/SourceFile:$SOURCE_PM_DB.bacpac  
echo "completed PM db restore"
sleep 20

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
/TargetDatabaseName:$TARGET_HIVE_DB \
/TargetUser:$TARGET_USER \
/TargetPassword:$TARGET_PASS \
/SourceFile:$SOURCE_HIVE_DB.bacpac  
echo "completed HIVE db restore"
sleep 20

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
/TargetDatabaseName:$TARGET_WD_DB \
/TargetUser:$TARGET_USER \
/TargetPassword:$TARGET_PASS \
/SourceFile:$SOURCE_WD_DB.bacpac  
echo "completed WD db restore"
sleep 20

sh upgrade_pm_hive.sh $CORE_SERVER_IP $CORE_SERVER_PORT $TARGET_SERVER $TARGET_CRC_DB $TARGET_ONT_DB $TARGET_PM_DB $TARGET_HIVE_DB $TARGET_WD_DB
echo "Completed backup and restore for all the databases."
echo "Run the mod_env_file script for updating environment variables."