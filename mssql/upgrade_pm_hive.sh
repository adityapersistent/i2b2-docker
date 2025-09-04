
CORE_SERVER_IP=$1
CORE_SERVER_PORT=$2

TARGET_SERVER=$3
TARGET_CRC_DB=$4
TARGET_ONT_DB=$5
TARGET_PM_DB=$6
TARGET_HIVE_DB=$7
TARGET_WD_DB=$8


export pm_sql="use i2b2pm;delete from PM_CELL_DATA;INSERT INTO PM_CELL_DATA (CELL_ID, PROJECT_PATH, NAME, METHOD_CD, URL, CAN_OVERRIDE, STATUS_CD) VALUES('CRC', '/', 'Data Repository', 'REST', 'http://i2b2-core-server:8080/i2b2/services/QueryToolService/', 1, 'A'),('FRC', '/', 'File Repository ', 'SOAP', 'http://i2b2-core-server:8080/i2b2/services/FRService/', 1, 'A'),('ONT', '/', 'Ontology Cell', 'REST', 'http://i2b2-core-server:8080/i2b2/services/OntologyService/', 1, 'A'),('WORK', '/', 'Workplace Cell', 'REST', 'http://i2b2-core-server:8080/i2b2/services/WorkplaceService/', 1, 'A'),('IM', '/', 'IM Cell', 'REST', 'http://i2b2-core-server:8080/i2b2/services/IMService/', 1, 'A');"


pm_sql=$(echo "$pm_sql" | sed "s/i2b2pm/$TARGET_PM_DB/g")
pm_sql=$(echo "$pm_sql" | sed "s/i2b2-core-server/$CORE_SERVER_IP/g")
pm_sql=$(echo "$pm_sql" | sed "s/8080/$CORE_SERVER_PORT/g")


echo $TARGET_SERVER
hive_sql="USE i2b2hive;update crc_db_lookup set c_db_fullschema = 'crc_db_name';update ont_db_lookup set c_db_fullschema = 'ont_db_name';update work_db_lookup set c_db_fullschema = 'wd_db_name' ;;"

hive_sql=$(echo "$hive_sql" | sed "s/i2b2hive/$TARGET_HIVE_DB/g")
hive_sql=$(echo "$hive_sql" | sed "s/crc_db_name/$TARGET_CRC_DB/g")
hive_sql=$(echo "$hive_sql" | sed "s/ont_db_name/$TARGET_ONT_DB/g")
hive_sql=$(echo "$hive_sql" | sed "s/wd_db_name/$TARGET_WD_DB/g")

docker exec -it i2b2-data-mssql bash -c "echo \"$pm_sql\" > /tmp/pm_sql.sql"
docker exec -it i2b2-data-mssql bash -c "echo \"$hive_sql\" > /tmp/hive_sql.sql"

echo "$pm_sql"
echo "$hive_sql"

docker exec -i i2b2-data-mssql /opt/mssql-tools/bin/sqlcmd -S $TARGET_SERVER -U $TARGET_USER -P $TARGET_PASS -i /tmp/pm_sql.sql
docker exec -i i2b2-data-mssql /opt/mssql-tools/bin/sqlcmd -S $TARGET_SERVER -U SA -P $TARGET_PASS -i /tmp/hive_sql.sql
