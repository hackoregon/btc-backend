Data Processing
=======================
Scraped data is loaded into raw data tables in a Postgres database and is then distributed out into working tables, containing refined data, and endpoint specific tables, containing data ready to be exported through Open Resty endpoints to the front end. 

When new data is added it must be propagated from the raw tables, forward to the working tables and the tables used by the endpoints. This process occurs once per day, when the scraper is run, and once when the back end is initially installed. The process is orchestrated by a set of bash scripts, which in turn call on R and sql scripts to do the actual data manipulation. 

When the back end is intitially installed, this bash script is used:
https://github.com/hackoregon/backend/blob/master/buildOutDBFromRawTables.sh

When new data is added in the daily scrape, this script is used:
https://github.com/hackoregon/backend/blob/master/loadEndpoints.sh
