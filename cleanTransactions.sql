INSERT INTO raw_committee_transactions_errors
(SELECT * 
FROM working_transactions 
WHERE tran_date > current_date);

DELETE FROM working_transactions
WHERE tran_date > current_date;

INSERT INTO raw_committee_transactions_errors
(SELECT * 
FROM working_transactions 
WHERE filed_date > current_date);

DELETE FROM working_transactions
WHERE filed_date > current_date;