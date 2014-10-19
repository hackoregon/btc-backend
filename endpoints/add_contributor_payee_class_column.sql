ALTER TABLE working_transactions DROP COLUMN IF EXISTS contributor_payee_class;
ALTER TABLE working_transactions ADD COLUMN contributor_payee_class varchar;

UPDATE  working_transactions
SET contributor_payee_class = 'grassroots_contributor'
WHERE 
(	book_type = 'Individual'
	OR
	book_type IS NULL)
AND
(
	(	contributor_payee IN
			(SELECT contributor_payee
			FROM sub_type_from_contributor_payee)
		AND sub_type IN
			('Cash Contribution', 'In-Kind Contribution')
	)
	OR 
	(	amount <= 200 
		AND sub_type IN ('Cash Contribution', 'In-Kind Contribution')
	)
);

SELECT addDocumentation('Calculation of grassroots',
	'committee_data_by_id, current_transactions, top_committee_data, candidate_search, competitors_from_filer_id, all_oregon_sum',
	'Grassroots donations are considered to be donations which 1) are $200 or less, 
	2) comefrom individuals and 3) have sub types Cash Contribution or In-Kind Contribution
	(thus, pledges are not included). 
	Small donations are occasionally lumped together and given a contributor name 
	indicating the lump sum came from donations of less than $100. 
	(ex: see transaction 984522, where the contributor_payee is given as 
	Miscellaneous Cash Contributions $100 and under )
	We count these transactions as grass roots donations, however these transactions are 
	not given a book_type (which incidates what types of entities contributions came from), 
	and thus there is some possibility that some of these transactions in fact come from 
	non-individuals (ex: businesses, political actions committees, etc. ). Thus, if and 
	where this occurs, our calculations will over-estimate the amount of grass roots donations.');
