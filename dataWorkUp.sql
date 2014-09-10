DROP TABLE IF EXISTS cc_working_trasactions;
CREATE TABLE cc_working_trasactions AS
(SELECT *
FROM working_trasactions
WHERE tran_date > '2010-11-11'::DATE);