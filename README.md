Hack Oregon Back End
=================

Endpoints
----------------------------------------------

Hack Oregon serves a collection of endpoints from an AWS instance using a combination of Postgresql and OpenResty.

For documentation on each of these endpoints and their usage, please see https://github.com/hackoregon/backend/blob/master/endpoint_readme.md

To request additional endpoints, if you have access to the google docs spreadsheet, 'Hackoregon punch list to deployment', please describe the endpoint requirements there and/or send an email to Sam. If you do not yet have access to that spreadsheet, please create a git hub issue here: https://github.com/hackoregon/backend/issues

To request access to the google docs spreadsheet, please send an email to sam at hackoregon dot org  . 

----------------------------------------------
Back end construction and installation
----------------------------------------------
To build an instance of Hack Oregon's back end on your own machine, please see https://github.com/hackoregon/backend/blob/master/backend_installation_readme.md . 

Once the back end is installed, there are several helper scripts that can help you run key functionality. 
Documentation for these scripts can be found here:
https://github.com/hackoregon/backend/blob/master/runningTheBackend.md


----------------------------------------------
The scraper
----------------------------------------------
We have a scraper and data cleaning infrastructure to import data from the Oregon Secretary of State website (ORESTAR). The data cleaning consists of R and python scripts orchestrated by a central bash script. The scraper is built with bash scripts and node.js.
