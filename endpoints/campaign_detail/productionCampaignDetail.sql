/*Make working_candidate_committees table*/

/* columns from working_committees
[1] "committee_id"                        "committee_name"                     
 [3] "committee_type"                      "committee_subtype"                  
 [5] "party_affiliation"                   "election_office"                    
 [7] "candidate_name"                      "candidate_email_address"            
 [9] "candidate_work_phone_home_phone_fax" "candidate_address"                  
[11] "treasurer_name"                      "treasurer_work_phone_home_phone_fax"
[13] "treasurer_mailing_address" 			"web_address"*/
/*
DROP TABLE IF EXISTS working_candidate_committees;
CREATE TABLE working_candidate_committees AS
(SELECT  candidate_name, committee_id, committee_name, 
		election_office, phone, 
		party_affiliation, web_address
	FROM working_committees);
*/
/*select * from working_candidate_committees where committee_type='CC';*/

/*Join with cc_grass_roots_in_state*/
DROP TABLE IF EXISTS campaign_detail;
CREATE TABLE campaign_detail AS
	(SELECT  
		candidate_name,
		filer as committee_name,
		simple_election as race, 
		web_address as website,
		phone,
		total_money as total,
		total_money_out as total_spent,
		percent_grass_roots as grassroots,
		percent_in_state as instate, 
		filer_id, 
		election_office as election,
		party_affiliation as party, 
		num_transactions, 
		committee_type, 
		committee_subtype,
		db_update_status
	FROM cc_grass_roots_in_state
	JOIN working_committees
	ON committee_id = cc_grass_roots_in_state.filer_id);



	
/*
select * from working_candidate_committees;
select * from cc_grass_roots_in_state;
select * from raw_committees;
*/
/*Find what is going on per race*/