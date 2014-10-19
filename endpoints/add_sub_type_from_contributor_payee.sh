#!/usr/bin/env bash
echo "Adding simplified sub types . . "

cd ~
cwd=$(pwd)
datadir="${cwd}/data_infrastructure/endpoints"

sudo -u postgres psql hackoregon -c  'drop table if exists sub_type_from_contributor_payee;'
sudo -u postgres psql hackoregon -c  'create table sub_type_from_contributor_payee ( contributor_payee varchar);'
sudo -u postgres psql hackoregon -c  "copy sub_type_from_contributor_payee from '${datadir}/grass_from_contributor_payee.txt' with (format csv, delimiter E'\t');"


# drop table if exists sub_type_from_contributor_payee;
# create table sub_type_from_contributor_payee ( contributor_payee varchar);
# copy sub_type_from_contributor_payee 
# from '/Users/samhiggins2001_worldperks/prog/hack_oregon/hackOregonBackEnd/endpoints/grass_from_contributor_payee.txt' 
# with (format csv, delimiter E'\t');
# echo "Adding column to working_transactions... "
# pwd
# sudo -u postgres psql hackoregon < ~/data_infrastructure/endpoints/add_contributor_payee_class_column.sql
# ls -l ~/data_infrastructure/endpoints/
# echo "simplified sub types added. " 