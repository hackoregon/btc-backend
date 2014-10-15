
/*
-total money received by committees
-from inside the political system (between committees)
-from outside the political system (from private citizen/company to a committee)

-total spent by committees

-on entities inside the political system (payments to other committees)
-on entities outside the political system (payments companies, contractors, citizens)

-total % out of state
-total % grassroots
*/

drop table if exists state_sum_by_date;
create table state_sum_by_date as
(select all_in.tran_date as tran_date, 
	total_in, total_out, 
	total_from_within, total_to_within, 
	total_from_the_outside, total_to_the_outside, 
	total_grass_roots, total_from_in_state
from
	(select tran_date, sum(amount) as total_in 
	from cc_working_transactions 
	where direction = 'in'
	group by tran_date) as all_in
join
	(select tran_date, sum(amount) as total_out 
	from cc_working_transactions 
	where direction = 'out'
	group by tran_date) as all_out	
on all_in.tran_date = all_out.tran_date
join 
	(select tran_date, sum(amount) as total_from_within
	from cc_working_transactions
	where direction = 'in'
	and book_type in ('Political Party Committee','Political Committee')
	group by tran_date ) as from_within
on all_in.tran_date  = from_within.tran_date
join 
	(select tran_date, sum(amount) as total_to_within
	from cc_working_transactions
	where direction = 'out'
	and book_type in ('Political Party Committee','Political Committee')
	group by tran_date ) as to_within
on all_in.tran_date  = to_within.tran_date
join 
	(select tran_date, sum(amount) as total_from_the_outside
	from cc_working_transactions
	where direction = 'in'
	and (book_type not in ('Political Party Committee','Political Committee')
	or book_type is null)
	group by tran_date ) as from_outside
on all_in.tran_date  = from_outside.tran_date
join 
	(select tran_date, sum(amount) as total_to_the_outside
	from cc_working_transactions
	where direction = 'out'
	and (book_type not in ('Political Party Committee','Political Committee')
	or book_type is null)
	group by tran_date ) as to_out
on all_in.tran_date  = to_out.tran_date
join
	(select tran_date, sum(amount) as total_grass_roots
	from cc_working_transactions
	where amount < 200
	and direction = 'in'
	group by tran_date ) as grass_roots
on all_in.tran_date  = grass_roots.tran_date
join
	(select tran_date, sum(amount) as total_from_in_state
	from cc_working_transactions
	where state='OR'
	and direction = 'in'
	group by tran_date ) as in_state
on all_in.tran_date  = in_state.tran_date);

DROP FUNCTION IF EXISTS http.get_state_sum_by_date(name1 text, name2 text, id text, name4 text);
CREATE FUNCTION http.get_state_sum_by_date(name1 text, name2 text, id text, name4 text) RETURNS json AS $$
DECLARE
  result json;
BEGIN

  SELECT array_to_json(array_agg(row_to_json(qres, true)), true)
  FROM 
    (SELECT *
    FROM state_sum_by_date) qres
  INTO result;
  
  return result;
END;
$$ LANGUAGE plpgsql;

/* select http.get_state_sum_by_date('','','',''); */

drop table if exists all_oregon_sum;
create table all_oregon_sum as
(select sum(total_in) as in, sum(total_out) as out, 
sum(total_from_within) as from_within, sum(total_to_within) as to_within, 
sum(total_from_the_outside) as from_outside, sum(total_to_the_outside) as to_outside,
sum(total_grass_roots) as total_grass_roots, sum(total_from_in_state) as total_from_in_state
from state_sum_by_date);

DROP FUNCTION IF EXISTS http.get_all_oregon_sum(name1 text, name2 text, id text, name4 text);
CREATE FUNCTION http.get_all_oregon_sum(name1 text, name2 text, id text, name4 text) RETURNS json AS $$
DECLARE
  result json;
BEGIN

  SELECT array_to_json(array_agg(row_to_json(qres, true)), true)
  FROM 
    (SELECT *
    FROM all_oregon_sum) qres
  INTO result;
  
  return result;
END;
$$ LANGUAGE plpgsql;



DROP FUNCTION IF EXISTS http.get_oregon_in_by_state(name1 text, name2 text, cname text, name4 text);
CREATE FUNCTION http.get_oregon_in_by_state(name1 text, name2 text, cname text, name4 text) RETURNS json AS $$
DECLARE
  result json;
BEGIN

  SELECT array_to_json(array_agg(row_to_json(qres, true)), true)
  FROM
    (SELECT state, sum(value)
    FROM candidate_by_state 
    where direction = 'in'
    group by state) qres
  INTO result;

  return result;
END;
$$ LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS http.get_oregon_out_by_state(name1 text, name2 text, cname text, name4 text);
CREATE FUNCTION http.get_oregon_out_by_state(name1 text, name2 text, cname text, name4 text) RETURNS json AS $$
DECLARE
  result json;
BEGIN

  SELECT array_to_json(array_agg(row_to_json(qres, true)), true)
  FROM
    (SELECT state, sum(value)
    FROM candidate_by_state 
    WHERE direction = 'out'
    GROUP BY state) qres
  INTO result;

  return result;
END;
$$ LANGUAGE plpgsql;

/*select http.get_all_oregon_sum('','','','');*/

/* select * from all_oregon_sum */
/*
create table activity_by_date as select tran_date, sum(amount) 
from cc_working_transactions
group by tran_date;
select * from activity_by_date order by tran_date;
select * from state_sum_by_date order by tran_date;
select sum(amount) from cc_working_transactions where book_type in ('Political Party Committee','Political Committee');
select sum(amount) from cc_working_transactions where book_type not in ('Political Party Committee','Political Committee');
select sum(amount) from cc_working_transactions where book_type is null;
select sum(amount) from cc_working_transactions;
select * from cc_working_transactions where book_type is null;
*/

/*
select * from candidate_sum_by_date

select distinct book_type from cc_working_transactions where contributor_payee_committee_id is not NULL;

select * from cc_working_transactions 
where book_type
in ('Political Party Committee','Political Committee')
and contributor_payee_committee_id is NULL;

select * from cc_working_transactions where contributor_payee_committee_id is not NULL
and book_type not in ('Individual', 'Business Entity', 'Other');
*/