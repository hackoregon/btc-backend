CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
CREATE OR REPLACE FUNCTION http.get_candidate_search(name1 text, name2 text, searchString text, name4 text) RETURNS json AS $$
DECLARE
  result json;
BEGIN

  SELECT array_to_json(array_agg(row_to_json(qres, true)), true)
  FROM
    (
		select *
		from campaign_detail
    where levenshtein(lower(searchString), lower(candidate_name), 1, 70, 70) < 131
		order by levenshtein(lower(searchString), lower(candidate_name), 1, 70, 70) 
		limit 20
    ) qres
  INTO result;

  return result;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION http.get_dqs_overly_optimistic_spelling(name1 text, name2 text, searchString text, name4 text) RETURNS json AS $$
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

