
#docker rm -f i2b2-data-mssql #uncomment this line if you have space issue
 
docker rm -f i2b2-core-server i2b2-webclient
docker compose up -d i2b2-core-server i2b2-webclient
 
echo "Started i2b2-core-server & i2b2-webclient Docker containers"
echo "logs of i2b2-core-server container - "
sleep 10
docker logs -f i2b2-core-server