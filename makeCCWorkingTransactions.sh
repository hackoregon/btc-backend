#!/usr/bin/env bash

echo "inside CCWorkingTransactions.sh"
echo "one argument must be provided to this script:"
echo "the begining date of the working campaign cycle"
echo "this must be provided in the format yyyy-mm-dd"
echo "ex:"
echo "2010-11-15"
echo "corresponds to a campaign cycle starting on November 15th, 2010"
echo "the argument that was passed: ${1}"

echo "---------------------------------------------------------------"
echo "Start of current campaign cycle set as: ${1} (yyyy-mm-dd)"
echo "---------------------------------------------------------------"

sudo -u postgres psql hackoregon -c "drop table if exists cc_working_transactions;"
sudo -u postgres psql hackoregon -c "create table cc_working_transactions as (select * from working_transactions where tran_date > '${1}'::date);"