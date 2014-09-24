
#!/usr/bin/env bash
echo "Running addDirectionCodes.sh"
echo "This script should only be envoked after ~/data_infrastructure/"
echo "has been built with buildOutFromGitRepo.sh"

cd ~
cwd=$(pwd)
datadir="${cwd}/data_infrastructure"

sudo -u postgres psql hackoregon -c  'drop table if exists direction_codes;'
sudo -u postgres psql hackoregon -c  'create table direction_codes ( sub_type varchar, direction varchar(7) );'
sudo -u postgres psql hackoregon -c  "copy direction_codes from '${datadir}/moneyDirectionCodes.txt' with (format csv, delimiter E'\t');"
