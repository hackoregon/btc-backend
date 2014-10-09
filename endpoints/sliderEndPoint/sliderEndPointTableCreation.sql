drop table if exists candidate_sum_by_date;
create table candidate_sum_by_date as
(select min.filer_id as filer_id, min.tran_date as tran_date, min.total as money_in, mout.total as money_out
from 
	(select filer_id, tran_date, sum(amount) as total 
	from cc_working_transactions 
	where direction = 'in'
	group by tran_date, filer_id) as min
join  
	(select filer_id, tran_date, sum(amount) as total 
	from cc_working_transactions 
	where direction = 'out'
	group by tran_date, filer_id) as mout
on min.tran_date = mout.tran_date
and min.filer_id = mout.filer_id);

/*select * from candidate_by_date;*/


DROP FUNCTION IF EXISTS http.get_candidate_sum_by_date(name1 text, name2 text, commID text, name4 text);
CREATE FUNCTION http.get_candidate_sum_by_date(name1 text, name2 text, commID text, name4 text) RETURNS json AS $$
DECLARE
  result json;
BEGIN

  SELECT array_to_json(array_agg(row_to_json(qres, true)), true)
  FROM 
    (SELECT *
    FROM candidate_sum_by_date
    WHERE filer_id=commID::integer) qres
  INTO result;
  
  return result;
END;
$$ LANGUAGE plpgsql;

/*select http.get_candidate_sum_by_date('', '', '470', '');*/