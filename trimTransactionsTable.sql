/*trimTransactionsTable.sql*/
ALTER TABLE raw_committee_transactions DROP COLUMN IF EXISTS  last_updated;
ALTER TABLE raw_committee_transactions DROP COLUMN IF EXISTS filer_vectors;
ALTER TABLE raw_committee_transactions DROP COLUMN IF EXISTS contributor_payee_vectors;
ALTER TABLE raw_committee_transactions DROP COLUMN IF EXISTS purp_desc_vectors;
ALTER TABLE raw_committee_transactions DROP COLUMN IF EXISTS all_vectors;

CREATE TABLE tmp_transactions AS SELECT * FROM raw_committee_transactions;
DROP TABLE raw_committee_transactions;
CREATE TABLE raw_committee_transactions AS SELECT * FROM tmp_transactions;
DROP TABLE tmp_transactions;


ALTER TABLE raw_committees DROP COLUMN IF EXISTS last_updated;
ALTER TABLE raw_committees DROP COLUMN IF EXISTS committee_name_vectors;
ALTER TABLE raw_committees DROP COLUMN IF EXISTS measure_vectors;
ALTER TABLE raw_committees DROP COLUMN IF EXISTS all_vectors;

CREATE TABLE tmp_committees AS SELECT * FROM raw_committees;
DROP TABLE raw_committees;
CREATE TABLE raw_committees AS SELECT * FROM tmp_committees;
DROP TABLE tmp_committees;