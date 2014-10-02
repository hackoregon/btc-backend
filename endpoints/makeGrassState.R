#!/usr/bin/Rscript
cat("\nInside makeGrassState.R: finding percent grass roots and percent in state...\n",
		"This script should be run with the arg <database name>,\n",
		"provided in this manner:\n",
		"makeGrassState.R hackoregon\n")
cat("\nWorking directory:",getwd(),"\n")
source("./orestar_scrape/productionCandidateCommitteeDataWithGrassroots.R")
source("./orestar_scrape/dbi.R")


args <- commandArgs(trailingOnly=TRUE)
DBNAME=args[1]

# startOfCurrentCampaignCycle = args[1]
# 
# cat("These arguments were passed to makeGrassState.R :\n","database name:",DBNAME,
# 		"\nstart Of Current Campaign Cycle:", startOfCurrentCampaignCycle, "\n" )
# 
# if(is.null(DBNAME)){
# 	DBNAME="hackoregon"
# 	message("Warning, database name not provided as the second arg to makeGrassState.R!",
# 					"Using the default, 'hackoregon'")
# }
# 
# if(is.null(startOfCurrentCampaignCycle)){
# 	startOfCurrentCampaignCycle = "2010-11-11"
# 	message("Warning, campaign cycle start date not provided as first arg to makeGrassState.R",
# 					"Using the default, 2010-11-11!")
# }

#these all go in buildEndpointTables.sh
# system("sudo -u postgres psql hackoregon < ")
#make cc_grass_roots_in_state

comSumWithGrass = exeGetCommitteeStatsIncGrass(dbname=DBNAME, cycle="current")#current cycle grass and in state
dbiWrite(tabla=comSumWithGrass, name="cc_grass_roots_in_state",append=F,dbname=DBNAME)
allTransactionsWithGrass = exeGetCommitteeStatsIncGrass( dbname=DBNAME, cycle="all")#all cycles grass and in state
dbiWrite(tabla=allTransactionsWithGrass, name="ac_grass_roots_in_state",append=F,dbname=DBNAME)
