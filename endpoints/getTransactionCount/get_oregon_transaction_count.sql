DROP FUNCTION IF EXISTS http.get_oregon_individual_transaction_count(name1 text, name2 text, transcount text, name4 text);


CREATE FUNCTION http.get_oregon_individual_transaction_count(name1 text, name2 text, transcount text, name4 text) RETURNS json AS $$ DECLARE RESULT json; BEGIN IF transcount='_' THEN transcount = '5'; END IF;
SELECT array_to_json(array_agg(row_to_json(qres, TRUE)), TRUE)
FROM
  (SELECT initcap(regexp_replace(contributor_payee, '\s+', ' ', 'g'))
    AS contributor_payee,
       count(tran_id)
   FROM cc_working_transactions
   WHERE book_type = 'Individual'
     AND sub_type IN ('Cash Contribution',
                      'In-Kind Contribution')
   GROUP BY contributor_payee
   ORDER BY count(tran_id) DESC LIMIT transcount::int) qres INTO RESULT; RETURN RESULT; END; $$ LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS http.get_oregon_business_transaction_count(name1 text, name2 text, transcount text, name4 text);


CREATE FUNCTION http.get_oregon_business_transaction_count(name1 text, name2 text, transcount text, name4 text) RETURNS json AS $$ DECLARE RESULT json; BEGIN IF transcount='_' THEN transcount = '5'; END IF;
SELECT array_to_json(array_agg(row_to_json(qres, TRUE)), TRUE)
FROM
  (SELECT initcap(contributor_payee)
    AS contributor_payee,
       count(tran_id)
   FROM cc_working_transactions
   WHERE book_type = 'Business Entity'
     AND sub_type IN ('Cash Contribution',
                      'In-Kind Contribution')
   GROUP BY contributor_payee
   ORDER BY count(tran_id) DESC LIMIT transcount::int) qres INTO RESULT; RETURN RESULT; END; $$ LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS http.get_oregon_political_committee_transaction_count(name1 text, name2 text, transcount text, name4 text);


CREATE FUNCTION http.get_oregon_political_committee_transaction_count(name1 text, name2 text, transcount text, name4 text) RETURNS json AS $$ DECLARE RESULT json; BEGIN IF transcount='_' THEN transcount = '5'; END IF;
SELECT array_to_json(array_agg(row_to_json(qres, TRUE)), TRUE)
FROM
  (SELECT initcap(contributor_payee) AS contributor_payee,
                                        count(tran_id)
   FROM cc_working_transactions
   WHERE book_type = 'Political Committee'
     AND sub_type IN ('Cash Contribution',
                      'In-Kind Contribution')
   GROUP BY contributor_payee
   ORDER BY count(tran_id) DESC LIMIT transcount::int) qres INTO RESULT; RETURN RESULT; END; $$ LANGUAGE plpgsql;

