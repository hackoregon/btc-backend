To create an endpoint:

With the help of Openresty and Postgres, endpoints can be created as sql functions returning JSON objects. An example of this can be seen here:

https://github.com/hackoregon/backend/blob/master/endpoints/getTransactions/get_current_candidate_transactions.sql

In this example, the function

	http.get_current_candidate_transactions(name1 text, name2 text, candidate_id text, name4 text) 

can be accessed from the URL

http://54.213.83.132/hackoregon/http/current_candidate_transactions/470/

where 470 is the candidate's committee ID number. 

Note that the function takes 4 parameters but only the third, candidate_id, is accessed in the acctual endpoint URL. 
Note also that every endpoint function must begin with 'http.get', but that part of the function name is omitted from the URL pattern. 

For details on how Openresty is used to connect postgres functions to URL endpoints, see the nginx config file/location subsection ( https://github.com/hackoregon/backend/blob/master/nginx.conf ) and the install.sql file ( https://github.com/hackoregon/backend/blob/master/install.sql ), specifically the function http.get(aschema text, afunction text, apath text, auser text) . 



To add an endpoint:

1) Place the endpoint creation script in the ./endpoints/<endpoint name>/ folder in the git repo and/or in the ~/data_infrastructure/endpoints/<endpoint name>/ in the actual server.

	1.5) 	If the script references any supplemental files, they should be placed in the endpoints folder along with the script. 
			The path to the endpoint's folder will be:
			
			~/data_infrastructure/endpoints/<endpoint name>/
			
2)	Add to the file buildEndpointTables.sh a call to your endpoint installation script. Please also add an echo'd message before the script call descriping what your install script is about to do (see the ones that are already there for examples.) If premissions for your script must be changed, have them changed here. 

3) If the new endpoint was installed directly into the server, run the script buildEndpointTables.sh. If the endpoint was installed in the git repo, make sure to sync everything up, then run the install3.sh script. 
