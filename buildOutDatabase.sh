#scripts to create the working tables and run the data workup

sudo -u postgres psql hackoregon < ~/gitforks/backend/workingTransactionsTableCreation.sql

sudo -u postgres psql hackoregon < ~/gitforks/backend/dataWorkUp.sql

sudo -u postgres psql hackoregon < ~/gitforks/backend/endpoints/candidateByState/candidate_by_state.sql















