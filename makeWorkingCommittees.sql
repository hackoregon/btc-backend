
drop table if exists working_committees;
create table working_committees as
(select committee_id, 
	committee_name, 
	committee_type, 
	committee_subtype, 
	party_descr as party_affiliation,
	candidate_work_phone as phone,
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

delete from working_committees where committee_id in 
	(select id from raw_committees_scraped);

insert into working_committees
	(select id as committee_id, 
		name as committee_name, 
		committee_type, 
		pac_type as committee_subtype, 
		candidate_party_affiliation as party_affiliation, 
		campaign_phone as phone,
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


UPDATE working_committees 
SET phone  = 'Candidate work/home/fax: '||candidate_work_phone_home_phone_fax
WHERE phone IS NULL
AND candidate_work_phone_home_phone_fax IS NOT NULL
AND candidate_work_phone_home_phone_fax != 'wk: hm: fx:';

UPDATE working_committees 
SET phone  = 'Treasurer work/fax: '||treasurer_work_phone_home_phone_fax
WHERE phone IS NULL
AND treasurer_work_phone_home_phone_fax IS NOT NULL
AND treasurer_work_phone_home_phone_fax !='wk: fx:';

UPDATE working_committees 
SET phone  = '(Phone number not found)'
WHERE phone IS NULL
OR phone = 'wk: hm: fx:';


ALTER TABLE working_committees ADD COLUMN simple_election text;
UPDATE working_committees SET simple_election = regexp_replace(election_office, 'Primary |General ','');

UPDATE working_committees
SET candidate_name = committee_name
WHERE candidate_name = '   '
OR candidate_name is null;


ALTER TABLE working_committees ADD COLUMN db_update_status text;
UPDATE working_committees SET db_update_status = 'Last full update: 3/14/2014' WHERE committee_id IN (SELECT committee_id FROM raw_committees);
UPDATE working_committees SET db_update_status = 'Last full update: 10/25/2014' WHERE committee_id IN (SELECT id FROM raw_committees_scraped);

