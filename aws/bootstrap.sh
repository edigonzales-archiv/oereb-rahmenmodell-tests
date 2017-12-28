export DB_HOST=geodb-dev.cgjofbdf5rqg.eu-central-1.rds.amazonaws.com
export DB_USER=stefan
export DB_DATABASE=sogis
export PGPASSWORD=ziegler15

sudo locale-gen de_CH.utf8
apt-get update
apt-get install -y postgresql-client-9.5

psql -h $DB_HOST -U $DB_USER -d postgres -c "CREATE DATABASE sogis OWNER $DB_USER;"
psql -h $DB_HOST -U $DB_USER -d $DB_DATABASE -c 'CREATE EXTENSION IF NOT EXISTS postgis;'
psql -h $DB_HOST -U $DB_USER -d $DB_DATABASE -c 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp";'
psql -h $DB_HOST -U $DB_USER -d $DB_DATABASE -c "CREATE ROLE oereb_read WITH LOGIN ENCRYPTED PASSWORD 'oereb_read';"

psql -h $DB_HOST -U $DB_USER -d $DB_DATABASE -c 'GRANT SELECT ON geometry_columns TO oereb_read;'
psql -h $DB_HOST -U $DB_USER -d $DB_DATABASE -c 'GRANT SELECT ON spatial_ref_sys TO oereb_read;'
psql -h $DB_HOST -U $DB_USER -d $DB_DATABASE -c 'GRANT SELECT ON geography_columns TO oereb_read;'
psql -h $DB_HOST -U $DB_USER -d $DB_DATABASE -c 'GRANT SELECT ON raster_columns TO oereb_read;'

apt-get --yes install unzip

add-apt-repository --yes ppa:webupd8team/java
apt-get update
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
apt-get --yes install oracle-java8-installer

mkdir -p /home/vagrant/apps/

cd ~
wget http://www.eisenhutinformatik.ch/interlis/ili2pg/ili2pg-3.11.0.zip -O ili2pg-3.11.0.zip
unzip -d /home/vagrant/apps/ ili2pg-3.11.0.zip
cd ~

cd ~
wget https://services.gradle.org/distributions/gradle-4.4.1-bin.zip -O gradle-4.4.1-bin.zip
unzip -d /home/vagrant/apps/ gradle-4.4.1-bin.zip
export PATH=$PATH:/home/vagrant/apps/gradle-4.4.1/bin
cd ~

# Import cadastral data (DM01)
java -jar /home/vagrant/apps/ili2pg-3.11.0/ili2pg.jar --dbhost $DB_HOST --dbdatabase $DB_DATABASE --dbusr $DB_USER --dbpwd $PGPASSWORD --nameByTopic --disableValidation --defaultSrsCode 2056 --strokeArcs --createFk --createGeomIdx --createFkIdx --createEnumTabs --beautifyEnumDispName --createBasketCol --createDatasetCol --createMetaInfo --importTid --models DM01AVSO24LV95 --dbschema av_avdpool_ng --schemaimport

gradle -I /vagrant/av_avdpool_ng/init.gradle -b /vagrant/av_avdpool_ng/build.gradle replaceAllDatasets --continue

psql -h $DB_HOST -U $DB_USER -d $DB_DATABASE -c 'GRANT USAGE ON SCHEMA av_avdpool_ng TO oereb_read;'
psql -h $DB_HOST -U $DB_USER -d $DB_DATABASE -c 'GRANT SELECT ON ALL TABLES IN SCHEMA av_avdpool_ng TO oereb_read;'

# Import PLZ-Ortschaft
wget http://data.geo.admin.ch/ch.swisstopo-vd.ortschaftenverzeichnis_plz/PLZO_INTERLIS_LV95.zip -O PLZO_INTERLIS_LV95.zip
unzip -d /home/vagrant/ PLZO_INTERLIS_LV95.zip

java -jar /home/vagrant/apps/ili2pg-3.11.0/ili2pg.jar --dbhost $DB_HOST --dbdatabase $DB_DATABASE --dbusr $DB_USER --dbpwd $PGPASSWORD --nameByTopic --disableValidation --defaultSrsCode 2056 --strokeArcs --createFk --createGeomIdx --createFkIdx --createEnumTabs --beautifyEnumDispName --createMetaInfo --importTid --models PLZOCH1LV95D --dbschema av_plzortschaft --import /home/vagrant/PLZO_INTERLIS_LV95/PLZO_ITF_LV95.itf

psql -h $DB_HOST -U $DB_USER -d $DB_DATABASE -c 'GRANT USAGE ON SCHEMA av_plzortschaft TO oereb_read;'
psql -h $DB_HOST -U $DB_USER -d $DB_DATABASE -c 'GRANT SELECT ON ALL TABLES IN SCHEMA av_plzortschaft TO oereb_read;'

# Import OEREB data (Transferstruktur)
java -jar /home/vagrant/apps/ili2pg-3.11.0/ili2pg.jar --dbhost $DB_HOST --dbdatabase $DB_DATABASE --dbusr $DB_USER --dbpwd $PGPASSWORD --createBasketCol --createDatasetCol --createMetaInfo --importTid --nameByTopic --disableValidation --defaultSrsCode 2056 --expandMultilingual --coalesceCatalogueRef --createFk --strokeArcs --createGeomIdx --createFkIdx --createEnumTabs --beautifyEnumDispName  --models "OeREBKRMvs_V1_1;OeREBKRMtrsfr_V1_1" --dbschema agi_oereb_trsfr --schemaimport

java -jar /home/vagrant/apps/ili2pg-3.11.0/ili2pg.jar --dbhost $DB_HOST --dbdatabase $DB_DATABASE --dbusr $DB_USER --dbpwd $PGPASSWORD --createBasketCol --createDatasetCol --createMetaInfo --importTid --nameByTopic --disableValidation --defaultSrsCode 2056 --expandMultilingual --coalesceCatalogueRef --createFk --strokeArcs --createGeomIdx --createFkIdx --createEnumTabs --beautifyEnumDispName --models OeREBKRMvs_V1_1 --dbschema agi_oereb_trsfr --dataset OeREBKRM_V1_1_Gesetze --import /vagrant/oereb-daten/ch/OeREBKRM_V1_1_Gesetze_20170101.xml

java -jar /home/vagrant/apps/ili2pg-3.11.0/ili2pg.jar --dbhost $DB_HOST --dbdatabase $DB_DATABASE --dbusr $DB_USER --dbpwd $PGPASSWORD --createBasketCol --createDatasetCol --createMetaInfo --importTid --nameByTopic --disableValidation --defaultSrsCode 2056 --expandMultilingual --coalesceCatalogueRef --createFk --strokeArcs --createGeomIdx --createFkIdx --createEnumTabs --beautifyEnumDispName --dbschema agi_oereb_trsfr --dataset OeREBKRM_V1_1_Codelisten --import /vagrant/oereb-daten/ch/OeREBKRM_V1_1_Codelisten_20170101.xml

java -jar /home/vagrant/apps/ili2pg-3.11.0/ili2pg.jar --dbhost $DB_HOST --dbdatabase $DB_DATABASE --dbusr $DB_USER --dbpwd $PGPASSWORD --createBasketCol --createDatasetCol --createMetaInfo --importTid --nameByTopic --disableValidation --defaultSrsCode 2056 --expandMultilingual --coalesceCatalogueRef --createFk --strokeArcs --createGeomIdx --createFkIdx --createEnumTabs --beautifyEnumDispName --models OeREBKRMtrsfr_V1_1 --dbschema agi_oereb_trsfr --dataset ch.bazl.sicherheitszonenplan --import /vagrant/oereb-daten/ch/ch.bazl.sicherheitszonenplan.oereb_20131118.xtf

java -jar /home/vagrant/apps/ili2pg-3.11.0/ili2pg.jar --dbhost $DB_HOST --dbdatabase $DB_DATABASE --dbusr $DB_USER --dbpwd $PGPASSWORD --createBasketCol --createDatasetCol --createMetaInfo --importTid --nameByTopic --disableValidation --defaultSrsCode 2056 --expandMultilingual --coalesceCatalogueRef --createFk --strokeArcs --createGeomIdx --createFkIdx --createEnumTabs --beautifyEnumDispName --models OeREBKRMtrsfr_V1_1 --dbschema agi_oereb_trsfr --dataset ch.bav.kataster-belasteter-standorte-oev --import /vagrant/oereb-daten/ch/ch.bav.kataster-belasteter-standorte-oev.oereb_20171012.xtf

java -jar /home/vagrant/apps/ili2pg-3.11.0/ili2pg.jar --dbhost $DB_HOST --dbdatabase $DB_DATABASE --dbusr $DB_USER --dbpwd $PGPASSWORD --createBasketCol --createDatasetCol --createMetaInfo --importTid --nameByTopic --disableValidation --defaultSrsCode 2056 --expandMultilingual --coalesceCatalogueRef --createFk --strokeArcs --createGeomIdx --createFkIdx --createEnumTabs --beautifyEnumDispName --models OeREBKRMtrsfr_V1_1 --dbschema agi_oereb_trsfr --dataset ch.bazl.kataster-belasteter-standorte-zivilflugplaetze --import /vagrant/oereb-daten/ch/ch.bazl.kataster-belasteter-standorte-zivilflugplaetze.oereb_20171012.xtf

java -jar /home/vagrant/apps/ili2pg-3.11.0/ili2pg.jar --dbhost $DB_HOST --dbdatabase $DB_DATABASE --dbusr $DB_USER --dbpwd $PGPASSWORD --createBasketCol --createDatasetCol --createMetaInfo --importTid --nameByTopic --disableValidation --defaultSrsCode 2056 --expandMultilingual --coalesceCatalogueRef --createFk --strokeArcs --createGeomIdx --createFkIdx --createEnumTabs --beautifyEnumDispName --models OeREBKRMtrsfr_V1_1 --dbschema agi_oereb_trsfr --dataset ch.bazl.projektierungszonen-flughafenanlagen --import /vagrant/oereb-daten/ch/ch.bazl.projektierungszonen-flughafenanlagen.oereb_20161128.xtf

psql -h $DB_HOST -U $DB_USER -d $DB_DATABASE -c 'GRANT USAGE ON SCHEMA agi_oereb_trsfr TO oereb_read;'
psql -h $DB_HOST -U $DB_USER -d $DB_DATABASE -c 'GRANT SELECT ON ALL TABLES IN SCHEMA agi_oereb_trsfr TO oereb_read;'

# Import NPLSO data and copy to Transferstruktur
# TODO