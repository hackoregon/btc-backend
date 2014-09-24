
#!/usr/bin/env bash
echo "--------------------------------"
echo "Building state_translation table"
echo "--------------------------------"

cd ~
cwd=$(pwd)
targetdir="${cwd}/data_infrastructure/endpoints/candidateByState/"

sudo -u postgres psql hackoregon -c 'DROP TABLE IF EXISTS state_translation;'
sudo -u postgres psql hackoregon -c 'CREATE TABLE state_translation ( StateFull varchar, Abbreviation varchar(3) );'
sudo -u postgres psql hackoregon -c "COPY state_translation FROM '${targetdir}StateAbbreviations.csv' DELIMITER ',' CSV HEADER;"

sudo -u postgres psql hackoregon <  "${targetdir}candidate_by_state.sql"
