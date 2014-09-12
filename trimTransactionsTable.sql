/*trimTransactionsTable.sql*/
ALTER TABLE raw_committee_transactions DROP COLUMN IF EXISTS  last_updated;
ALTER TABLE raw_committee_transactions DROP COLUMN IF EXISTS filer_vectors;
ALTER TABLE raw_committee_transactions DROP COLUMN IF EXISTS contributor_payee_vectors;
ALTER TABLE raw_committee_transactions DROP COLUMN IF EXISTS purp_desc_vectors;
ALTER TABLE raw_committee_transactions DROP COLUMN IF EXISTS all_vectors;