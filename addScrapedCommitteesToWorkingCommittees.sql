/*add scraped committees into working commitees*/

delete from working_committees where committee_id in 
	(select id from raw_committees_scraped);

insert into working_committees
	(select id as committee_id, 
		name as committee_name, 
		committee_type, 
		pac_type as committee_subtype, 
		campaign_phone as phone,
		candidate_party_affiliation as party_affiliation, 
		candidate_election_office as election_office, 
		candidate_name, 
		candidate_email_address, 
		candidate_work_phone_home_phone_fax, 
		candidate_candidate_address as candidate_address,  
		treasurer_name, 
		treasurer_work_phone_home_phone_fax, 
		treasurer_mailing_address, 
		NULL as web_address
	from raw_committees_scraped);


