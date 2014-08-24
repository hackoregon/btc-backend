/*add direction codes*/
drop table if exists direction_codes;
create table direction_codes (
sub_type varchar,
direction varchar(7)
)

copy direction_codes from '/home/ubuntu/gitforks/backend/moneyDirectionCodes.txt' with (format csv, delimiter E'\t');
