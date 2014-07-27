BEGIN;
DROP SCHEMA IF EXISTS http CASCADE;
CREATE SCHEMA http;


CREATE FUNCTION http.get_one_committee(name1 text, name2 text, name3 text, name4 text) RETURNS SETOF raw_committees AS $$
  select *
  from raw_committees
  where committee_id in (2752,4212);
$$ LANGUAGE SQL;


CREATE FUNCTION http.get(aschema text, afunction text, apath text, auser text) RETURNS json AS $$
DECLARE
  args text;
  result json;
BEGIN
    SELECT array_to_string(array_agg(
        (SELECT quote_literal(a[1]) || coalesce('::' || b[2], '')
         FROM regexp_split_to_array(row, E'::') AS a,
              regexp_split_to_array(row, E'::') AS b)
              ), ',')
    FROM unnest(regexp_split_to_array(apath, E'\/')) AS row INTO args;
    args := format('SELECT array_to_json(array_agg(row_to_json(row, true)), true) FROM %I.%I(%L, %s) as row;', aschema, 'get_' || afunction, auser, args);
    RAISE NOTICE '%', args;
    EXECUTE args into result;
    RETURN result;
END;
$$ LANGUAGE plpgsql;
COMMIT;