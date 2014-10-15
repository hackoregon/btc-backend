Data Processing
=======================
Scraped data is loaded into raw data tables in Postgres database and is then distributed out into working tables, containing refined data, and endpoint specific table, containing data ready to be exported through Open Resty endpoints to the front end. 

When new data is added it must be propagated from the raw tables, forward to the tables used by the endpoints. This process occurs once per day, when the scraper is run, and is controlled by a set of bash scripts, which in turn call on R and sql scripts to do the actual data manipulation. 
