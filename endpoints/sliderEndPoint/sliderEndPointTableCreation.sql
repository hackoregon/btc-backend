drop table if exists candidate_sum_by_date;
create table candidate_sum_by_date as
(select all_in.filer_id as filer_id, all_in.tran_date as tran_date, total_in, total_out
from
	(select sub.filer_id as filer_id, sub.tran_date as tran_date, total_in
	from	(select filer_id, tran_date, sum(amount) as total_in 
		from cc_working_transactions 
		where direction = 'in'
		group by tran_date, filer_id) as sub0
	right join
		(select distinct filer_id, tran_date 
		from cc_working_transactions) as sub
	on sub0.filer_id = sub.filer_id
	and sub0.tran_date = sub.tran_date) as all_in
join
	(select sub.filer_id as filer_id, sub.tran_date as tran_date, total_out
	from	(select filer_id, tran_date, sum(amount) as total_out 
		from cc_working_transactions 
		where direction = 'out'
		group by tran_date, filer_id) as sub0
	right join
		(select distinct filer_id, tran_date 
		from cc_working_transactions) as sub
	on sub0.filer_id = sub.filer_id
	and sub0.tran_date = sub.tran_date) as all_out
on all_in.filer_id = all_out.filer_id
and all_in.tran_date = all_out.tran_date);


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
    WHERE filer_id=commID::integer
    ORDER BY tran_date ASC) qres
  INTO result;
  
  return result;
END;
$$ LANGUAGE plpgsql;

/*select http.get_candidate_sum_by_date('', '', '470', '');*/
