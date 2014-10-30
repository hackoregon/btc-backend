drop table if exists working_transactions;
create table working_transactions
	as (
		select tran_id, tran_date, filer, contributor_payee, rct.sub_type, amount, 
		contributor_payee_committee_id, filer_id, purp_desc, book_type, addr_line1, filed_date,
		addr_line2, city, state, zip, purpose_codes, dc.direction as direction
		from raw_committee_transactions rct
		join direction_codes dc
		on dc.sub_type = rct.sub_type
		);

INSERT INTO raw_committee_transactions_errors
	SELECT * 
	FROM raw_committee_transactions 
	WHERE raw_committee_transactions.tran_id IN
		(SELECT tran_id
		FROM working_transactions 
		WHERE tran_date > current_date);

DELETE FROM working_transactions
WHERE tran_date > current_date;

INSERT INTO raw_committee_transactions_errors
	SELECT * 
	FROM raw_committee_transactions 
	WHERE raw_committee_transactions.tran_id IN
		(SELECT tran_id
		FROM working_transactions 
		WHERE filed_date > current_date);

DELETE FROM working_transactions
WHERE filed_date > current_date;

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