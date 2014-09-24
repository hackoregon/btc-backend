select * from test_raw_transactions;

alter table test_raw_transactions drop column direction;
alter table test_raw_transactions add column exp_date date;


select maximum tran_date from test_raw_transactions;


select max(tran_date) from raw_committee_transactions;
select min(tran_date) from raw_committee_transactions;

select * from test_raw_transactions;

select distinct tran_date from test_raw_transactions order by tran_date;
select distinct tran_id from test_raw_transactions;

DELETE FROM test_raw_transactions
WHERE tran_id in 
( select distinct tran_id from test_raw_transactions );

select count(*)
from test_raw_transactions
group by tran_id
order by count(*) desc
limit 1;

select * from test_raw_transactions where tran_id in
(select original_id
from test_raw_transactions
where tran_status = 'Amended');

drop table amended_transactions;

create table amended_transactions as
select * from raw_committee_transactions
where filer='USA';

drop table test_raw_transactions_ammended_transactions;

/*get the ammended transactions*/
select tran_id 
from test_raw_transactions 
where tran_id in
(select original_id
from test_raw_transactions
where tran_status = 'Amended');

where tran_id in






insert into amended_transactions 
select * from test_raw_transactions where tran_id in
(select original_id
from test_raw_transactions
where tran_status = 'Amended' );

select * from test_raw_transactions order by tran_date;


update test_raw_transactions
set tran_id = 
(select original_id
from test_raw_transactions
where tran_status = 'Amended' 
limit 1)
where tran_id in
(select tran_id from test_raw_transactions limit 1);


select distinct tran_date from raw_committee_transactions order by tran_date asc limit 1

select tran_date, tran_id from raw_committee_transactions order by tran_id asc;

select * 
from test_raw_transactions
where tran_id in
(select tran_id
from test_raw_transactions
group by tran_id
having count(*) > 1)
order by tran_id


select tran_id, count(*)
from test_raw_transactions
group by tran_id
order by count(*) desc

