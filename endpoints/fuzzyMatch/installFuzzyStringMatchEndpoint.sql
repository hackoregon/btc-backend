CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
CREATE OR REPLACE FUNCTION http.get_candidate_search(name1 text, name2 text, searchString text, name4 text) RETURNS json AS $$
DECLARE
  result json;
BEGIN

  SELECT array_to_json(array_agg(row_to_json(qres, true)), true)
  FROM
    (
      select * from campaign_detail
      where dmetaphone( candidate_name ) ilike '%'||dmetaphone( searchString )||'%'
    ) qres
  INTO result;

  return result;
END;
$$ LANGUAGE plpgsql;