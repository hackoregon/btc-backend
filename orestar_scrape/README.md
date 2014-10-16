Orestar Scraper
=================

The Hack Oregon 'Behind the Curtain' project uses financial transaction data, political committee data and Candidate filings data obtained from the Oregon Secretary of State's website
( http://sos.oregon.gov/elections/Pages/orestar.aspx ). 
This data must be scraped using two different approaches: one for the transaction data and one for the committee data.

Transaction data
------------------
The transaction data can be obtained as excel documents, each with a maximum size of 5000 lines (header + 4999 records), by passing a date range to this web form:

https://secure.sos.state.or.us/orestar/gotoPublicTransactionSearch.do

A scraper was built in javascript to automate downloading of transaction data from this web form. Documentation for using this transactions scraper can be found here:
https://github.com/hackoregon/backend/blob/master/orestar_scrape/transaction_scraper_README.md

Committee data
------------------
Committee data is obtained by scraping JSON objects directly out of the web page returned by passing a committee id to this web form:

https://secure.sos.state.or.us/orestar/GotoSearchByName.do

A scraper was built in javascript to automate downloading of committee data from this web form.
Documentation for the committee scraper can be found here:

https://github.com/hackoregon/backend/blob/master/orestar_scrape/orestar_scrape_committees/README.md

Orestar does provide a form to download Excel sheets of committee data by the date the committees were registered, but in our experience, data for many committees (ex: John Kitzhaber's election committee) will come up missing if this technique is used. 

Candidate filings data
------------------
This table is currently between 2000 and 3000 lines and can be downloaded as a single excel document.
Currently this table manually downloaded, but a scraper is being tested.  
