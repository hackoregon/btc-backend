drop table if exists working_transactions;
create table working_transactions
	as (
		select tran_id, tran_date, filer, contributor_payee, rct.sub_type, amount, 
		contributor_payee_committee_id, filer_id, purp_desc, book_type, addr_line1, 
		addr_line2, city, state, zip, purpose_codes, dc.direction as direction
		from raw_committee_transactions rct
		join direction_codes dc
		on dc.sub_type = rct.sub_type
		);

ALTER TABLE working_transactions DROP COLUMN IF EXISTS contributor_payee_class;
ALTER TABLE working_transactions ADD COLUMN contributor_payee_class varchar;

UPDATE  working_transactions
SET contributor_payee_class = 'grassroots_contributor'
WHERE (contributor_payee IN
	(SELECT contributor_payee
	FROM sub_type_from_contributor_payee)
AND sub_type IN
		('Cash Contribution', 'In-Kind Contribution')
	)
OR 	( amount <= 200 
	AND sub_type IN
		('Cash Contribution', 'In-Kind Contribution') 
	);
