
drop table if exists direction_codes;
create table direction_codes (
sub_type varchar,
direction varchar(7)
);

copy direction_codes from '/Users/samhiggins2001_worldperks/prog/hack_oregon/moneyDirectionCodes.txt' with (format csv, delimiter E'\t');

drop table if exists working_trasactions;
create table working_trasactions
	as (
		select tran_id, tran_date, filer, contributor_payee, rct.sub_type, amount, 
		contributor_payee_committee_id, filer_id, purp_desc, book_type, addr_line1, 
		addr_line2, city, state, zip, purpose_codes, dc.direction as direction
		from raw_committee_transactions rct
		join direction_codes dc
		on dc.sub_type = rct.sub_type
		);
