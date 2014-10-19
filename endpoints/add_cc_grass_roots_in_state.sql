DROP TABLE IF EXISTS cc_grass_roots_in_state;
CREATE TABLE cc_grass_roots_in_state AS
(SELECT committee_type, 
	candidate_name, 
	phone, 
	party, 
	in_state.filer_id as filer_id, 
	filer, 
	in_state, 
	grass AS grass_roots, 
	total_contributions, 
	money_in as total_money, 
	money_out as total_money_out
FROM 
	(SELECT filer_id, sum(amount) AS in_state
	FROM cc_working_transactions
	WHERE state = 'OR'
	AND sub_type IN ('Cash Contribution', 'In-Kind Contribution')
	GROUP BY filer_id) AS in_state
JOIN 
	(SELECT filer_id, sum(amount) AS grass
	FROM cc_working_transactions
	WHERE contributor_payee_class = 'grassroots_contributor'
	GROUP BY filer_id) AS grass
ON in_state.filer_id = grass.filer_id
JOIN 
	(SELECT filer_id, sum(amount) AS total_contributions
	FROM cc_working_transactions
	WHERE sub_type IN ('Cash Contribution', 'In-Kind Contribution')
	GROUP BY filer_id) AS total_contributions
ON in_state.filer_id = total_contributions.filer_id
JOIN
	(SELECT filer_id, sum(amount) AS money_in
	FROM cc_working_transactions
	WHERE direction = 'in'
	GROUP BY filer_id) as money_in
ON in_state.filer_id = money_in.filer_id
JOIN
	(SELECT filer_id, sum(amount) AS money_out
	FROM cc_working_transactions
	WHERE direction = 'out'
	GROUP BY filer_id) as money_out
ON in_state.filer_id = money_out.filer_id
LEFT OUTER JOIN 
	(SELECT committee_id, 
		committee_type, 
		committee_name AS filer, 
		candidate_name, 
		candidate_work_phone_home_phone_fax AS phone, 
		party_affiliation AS party
	FROM working_committees) AS committee_data
ON in_state.filer_id = committee_data.committee_id);

ALTER TABLE cc_grass_roots_in_state
ADD COLUMN percent_grass_roots real;

ALTER TABLE cc_grass_roots_in_state
ADD COLUMN percent_in_state real;

UPDATE cc_grass_roots_in_state
SET percent_grass_roots = grass_roots/total_contributions;

UPDATE cc_grass_roots_in_state
SET percent_in_state = in_state/total_contributions;

UPDATE cc_grass_roots_in_state
SET candidate_name = filer
WHERE candidate_name = '   '
OR candidate_name is null;
