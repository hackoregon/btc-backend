orstarparse
============
How to run

```
npm install

node scraper DATESTART DATEEND DELAY_IN_SECONDS(Defaults to 10 seconds)


EXAMPLE:
//Will start at August 12 and ouput weekly files for the last month and delay requests every 5 seconds
node scraper 08/12/2014 07/12/2014 5
```

This will dump STARTWEEKDATE_ENDWEEKDATE.xls files into the scraper folder.


--------------------
Notes on ORESTAR
--------------------
Orestar will give a maximum of 5000 lines at once (including the header, so 4999 records). Thus if more than 4999 records are returned in a search result, only the first 4999 records will be returned, ordered by date, descending. 
The R script running the scraper is built to check if each returned records set has exactly 4999 lines, and make additional requests to fill in missing records as needed.
