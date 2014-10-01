/*Make working_candidate_committees table*/

/* columns from working_committees
[1] "committee_id"                        "committee_name"                     
 [3] "committee_type"                      "committee_subtype"                  
 [5] "party_affiliation"                   "election_office"                    
 [7] "candidate_name"                      "candidate_email_address"            
 [9] "candidate_work_phone_home_phone_fax" "candidate_address"                  
[11] "treasurer_name"                      "treasurer_work_phone_home_phone_fax"
[13] "treasurer_mailing_address" 			"web_address"*/

DROP TABLE IF EXISTS working_candidate_committees;
CREATE TABLE working_candidate_committees AS
(SELECT  candidate_name, committee_id, committee_name, 
		election_office, candidate_work_phone_home_phone_fax as phone, 
		party_affiliation, web_address
	FROM working_committees
	WHERE committee_type='CC');

/*select * from working_candidate_committees where committee_type='CC';*/

/*Join with cc_grass_roots_in_state*/
DROP TABLE IF EXISTS campaign_detail;
CREATE TABLE campaign_detail AS
	(SELECT candidate_name, 
		committee_name,
		election_office as race, 
		web_address as website,
		phone,
		total_money as total,
		percent_grassroots as grassroots,
		percent_instate as instate, 
		filer_id, 
		party_affiliation as party
	FROM 
		(SELECT filer_id, total_money, percent_grassroots, percent_instate
		FROM cc_grass_roots_in_state) as sub1
	JOIN working_candidate_committees
	ON committee_id = sub1.filer_id);
/*
select * from campaign_detail;
select * from cc_grass_roots_in_state;
select * from raw_committees;
*/
/*Find what is going on per race*/