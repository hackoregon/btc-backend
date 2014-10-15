drop function if exists http.get_current_candidate_transactions(name1 text, name2 text, candidate_id text, name4 text);
CREATE FUNCTION http.get_current_candidate_transactions(name1 text, name2 text, candidate_id text, name4 text) RETURNS json AS $$
DECLARE
  result json;
BEGIN

  SELECT array_to_json(array_agg(row_to_json(qres, true)), true)
  FROM 
    (SELECT *
    FROM cc_working_transactions
    WHERE filer_id = candidate_id::integer
    ORDER BY tran_date DESC) qres
  INTO result;
  
  return result;
END;
$$ LANGUAGE plpgsql;