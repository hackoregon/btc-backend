

DROP TABLE IF EXISTS cc_grass_roots_in_state;
CREATE TABLE cc_grass_roots_in_state AS
(SELECT 
	all_trans.filer_id AS filer_id, 
	filer, 
	num_transactions,
	in_state, 
	grass AS grass_roots, 
	total_contributions, 
	money_in AS total_money, 
	money_out AS total_money_out
FROM (SELECT DISTINCT filer_id
	FROM cc_working_transactions) AS all_trans
LEFT OUTER JOIN
	(SELECT filer_id, sum(amount) AS in_state
	FROM cc_working_transactions
	WHERE state = 'OR'
	AND sub_type IN ('Cash Contribution', 'In-Kind Contribution')
	GROUP BY filer_id) as in_state
on all_trans.filer_id = in_state.filer_id
LEFT OUTER JOIN 
	(SELECT filer_id, sum(amount) AS grass
	FROM cc_working_transactions
	WHERE contributor_payee_class = 'grassroots_contributor'
	GROUP BY filer_id) AS grass
ON all_trans.filer_id = grass.filer_id
LEFT OUTER JOIN
	(SELECT filer_id, sum(amount) AS money_in
	FROM cc_working_transactions
	WHERE direction = 'in'
	GROUP BY filer_id) as money_in
ON all_trans.filer_id = money_in.filer_id
LEFT OUTER JOIN
	(SELECT filer_id, sum(amount) AS money_out
	FROM cc_working_transactions
	WHERE direction = 'out'
	GROUP BY filer_id) as money_out
ON all_trans.filer_id = money_out.filer_id
LEFT OUTER JOIN 
	(SELECT filer_id, sum(amount) AS total_contributions
	FROM cc_working_transactions
	WHERE sub_type IN ('Cash Contribution', 'In-Kind Contribution')
	GROUP BY filer_id) AS total_contributions
ON all_trans.filer_id = total_contributions.filer_id
LEFT OUTER JOIN
	(SELECT filer_id, count(*) AS num_transactions
	FROM cc_working_transactions
	GROUP BY filer_id) AS trans_count
ON all_trans.filer_id = trans_count.filer_id
LEFT OUTER JOIN 
	(SELECT committee_id AS filer_id, committee_name AS filer
	FROM working_committees) AS committee_data
ON all_trans.filer_id = committee_data.filer_id);

ALTER TABLE cc_grass_roots_in_state
ADD COLUMN percent_grass_roots real;

ALTER TABLE cc_grass_roots_in_state
ADD COLUMN percent_in_state real;

UPDATE cc_grass_roots_in_state
SET percent_grass_roots = grass_roots/total_contributions;

UPDATE cc_grass_roots_in_state
SET percent_in_state = in_state/total_contributions;


SELECT addDocumentation('How is Grassroots calculated?',
	'campaign_detail',
	'Grassroots contibutions are contributions which are marked In-Kind or Cash Contribution, are of $200 or less and which come from Individuals.  Contributions of $100 and less are occasionally reported in bulk and given contributor_payee names such as Miscellaneous Cash Contributions $100 and under; these contributions are considered to be grassroots as well. 
	It is noted that contributions reported in bulk may contain contributions from non-Individuals (ex: businesses or political committees), thus our calculations may over-estimate the true grassroots support a committee or candidate actually has.');


