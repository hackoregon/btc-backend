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