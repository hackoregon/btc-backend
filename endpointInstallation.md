To add an endpoint:

1) Place the endpoint creation scrip in the ./endpoints/<endpoint name>/ folder in the git repo and/or in the ~/data_infrastructure/endpoints/<endpoint name>/ in the actual server.
	1.5) 	If the script references any supplemental files, they should be place in the endpoints folder along with the script. 
			The path to the endpoint's folder will be ~/data_infrastructure/endpoints/<endpoint name>/
2)	Add to the file buildEndpointTables.sh a call to your endpoint installation script. Please also add an echo'd message before the script call descriping what your install script is about to do (see the ones that are already there for examples.) If premissions for your script must be changed, have them changed here. 
3) If the new endpoint was installed directly into the server, run the script buildEndpointTables.sh. If the endpoint was installed in the git repo, make sure to sync everything up, then run the install3.sh script. 
