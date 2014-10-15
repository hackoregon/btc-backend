drop table if exists working_committees;
create table working_committees as
(select committee_id, 
	committee_name, 
	committee_type, 
	committee_subtype, 
	party_descr as party_affiliation,
	concat(active_election, ' ', candidate_office_group,' ',raw_committees.candidate_office) as election_office, 
	candidate_first_name ||' '|| candidate_last_name as candidate_name,
	candidate_email as candidate_email_address,
	concat('wk:', candidate_work_phone,' hm:', candidate_residence_phone, ' fx:', candidate_fax) as "candidate_work_phone_home_phone_fax", 
	candidate_maling_address as candidate_address, 
	concat(treasurer_first_name,' ',treasurer_last_name) as treasurer_name,
	concat('wk:',treasurer_work_phone,' fx:', treasurer_fax) as treasurer_work_phone_home_phone_fax,
	treasurer_mailing_address, 
	web_address, 
	measure
from raw_committees
left outer join working_candidate_filings on raw_committees.candidate_first_name = working_candidate_filings.first_name
and raw_committees.candidate_last_name = working_candidate_filings.last_name);

