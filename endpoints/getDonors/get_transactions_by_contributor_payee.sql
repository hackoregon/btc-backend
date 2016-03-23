DROP FUNCTION IF EXISTS http.get_transactions_by_contributor_payee(name1 text, name2 text, donor_name text, name4 text);
CREATE FUNCTION http.get_transactions_by_contributor_payee(name1 text, name2 text, donor_name text, name4 text) RETURNS json AS $$
DECLARE
  result json;
BEGIN

  SELECT array_to_json(array_agg(row_to_json(qres, true)), true)
  FROM
		(SELECT *
    FROM cc_working_transactions
    WHERE contributor_payee = donor_name::text
    ORDER BY tran_date DESC) qres
  INTO result;

  return result;
END;
$$ LANGUAGE plpgsql;