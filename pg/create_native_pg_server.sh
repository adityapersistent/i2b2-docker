sudo apt-get update

sudo apt-get install -y postgresql-16 postgresql-contrib-16
sudo sed -i "s/local   all             postgres                                peer/local   all             postgres                                trust/" /etc/postgresql/16/main/pg_hba.conf
service postgresql restart

echo "waiting for postgresql to start"
sleep 60

psql -U postgres -c "ALTER USER postgres PASSWORD 'demouser';"
psql -U postgres -c "CREATE DATABASE i2b2;"
psql -U postgres -c "CREATE USER i2b2 WITH SUPERUSER ENCRYPTED PASSWORD 'demouser'; GRANT ALL PRIVILEGES ON DATABASE i2b2 TO i2b2; commit;"

sed -i "0,/#listen_addresses = 'localhost'/s/#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/16/main/postgresql.conf


sudo sed -i '/^host/s/ident/md5/' /etc/postgresql/16/main/pg_hba.conf
sudo sed -i '/^local/s/peer/trust/' /etc/postgresql/16/main/pg_hba.conf
sudo sed -i "s/local   all             postgres                                trusts/local   all             postgres                                peer/" /etc/postgresql/16/main/pg_hba.conf
echo "host all all 0.0.0.0/0 md5" | sudo tee -a /etc/postgresql/16/main/pg_hba.conf

service postgresql restart
