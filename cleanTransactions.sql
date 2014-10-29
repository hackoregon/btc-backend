INSERT INTO raw_committee_transactions_errors
(SELECT * 
FROM raw_committee_transactions 
WHERE tran_date > current_date);

DELETE FROM raw_committee_transactions
WHERE tran_date > current_date;

INSERT INTO raw_committee_transactions_errors
(SELECT * 
FROM raw_committee_transactions 
WHERE filed_date > current_date);

DELETE FROM raw_committee_transactions
WHERE filed_date > current_date;