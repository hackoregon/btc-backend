
DROP FUNCTION IF EXISTS http.get_all_transactions_by_date(name1 text, name2 text, req_date text, name4 text);


CREATE FUNCTION http.get_all_transactions_by_date(name1 text, name2 text, req_date text, name4 text) RETURNS json AS $$ DECLARE RESULT json; BEGIN IF req_date='_' THEN req_date = CURRENT_DATE - interval '1 day'; END IF;
SELECT array_to_json(array_agg(row_to_json(qres, TRUE)), TRUE)
FROM
  (SELECT *
   FROM cc_working_transactions
   WHERE tran_date = req_date::date
   ORDER BY amount DESC) qres INTO RESULT; RETURN RESULT; END; $$ LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS http.get_all_new_transactions(name1 text, name2 text, transcount text, name4 text);


CREATE FUNCTION http.get_all_new_transactions(name1 text, name2 text, transcount text, name4 text) RETURNS json AS $$ DECLARE RESULT json; BEGIN IF transcount='_' THEN transcount = '10'; END IF;
SELECT array_to_json(array_agg(row_to_json(qres, TRUE)), TRUE)
FROM
  (SELECT *
   FROM cc_working_transactions
   WHERE filed_date >= (now() - '2 day'::INTERVAL)
   ORDER BY amount DESC, filed_date DESC LIMIT transcount::int) qres INTO RESULT; RETURN RESULT; END; $$ LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS http.get_current_candidate_week_transactions(name1 text, name2 text, candidate_id text, name4 text);


CREATE FUNCTION http.get_current_candidate_week_transactions(name1 text, name2 text, candidate_id text, name4 text) RETURNS json AS $$ DECLARE RESULT json; BEGIN
SELECT array_to_json(array_agg(row_to_json(qres, TRUE)), TRUE)
FROM
  (SELECT *
   FROM cc_working_transactions
   WHERE filer_id = candidate_id::integer
     AND filed_date >= (now() - '1 week'::INTERVAL)
   ORDER BY amount DESC, filed_date) qres INTO RESULT; RETURN RESULT; END; $$ LANGUAGE plpgsql;