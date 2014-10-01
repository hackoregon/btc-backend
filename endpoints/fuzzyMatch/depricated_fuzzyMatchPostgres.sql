CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;

select * from raw_candidate_filings
where dmetaphone( "Cand_Ballot_Name_Txt" )  = dmetaphone( 'Bl' )
or "Cand_Ballot_Name_Txt" like 'bill%';

select dmetaphone( 'Bil Daltun' ) ;

select * from raw_candidate_filings
where "Cand_Ballot_Name_Txt" like '%ill%'
or dmetaphone( "Cand_Ballot_Name_Txt" )  = dmetaphone( 'Bl' );

select * from campaign_detail;


drop function if exists http.get_candidate_search(name1 text, name2 text, searchString text, name4 text);
CREATE FUNCTION http.get_candidate_search(name1 text, name2 text, searchString text, name4 text) RETURNS json AS $$
DECLARE
  result json;
BEGIN
w
  SELECT array_to_json(array_agg(row_to_json(qres, true)), true)
  FROM 
    (
	select * from campaign_detail
	where dmetaphone( candidate_name ) ilike '%'||dmetaphone( 'bill' )||'%'
    ) qres
  INTO result;
  
  return result;
END;
$$ LANGUAGE plpgsql;

select http.get_candidate_search('test','test','bill','test');

select * 
from raw_candidate_filings
where dmetaphone( "Cand_Ballot_Name_Txt" )  
ilike '%'||dmetaphone( 'Bill gard' )||'%'

select * from campaign_detail
where candidate_name ilike '%'||searchString||'%'
or dmetaphone( candidate_name )  = dmetaphone( searchString )