
DROP TABLE IF EXISTS candidate_by_state;
CREATE TABLE candidate_by_state AS
        (
        SELECT  candidate_name, sub1.filer_id as filer_id, "statefull" AS state, direction, value
        FROM
                (SELECT filer_id, state, direction, sum(amount) AS value
                FROM cc_working_transactions
                GROUP BY filer_id, state, direction) sub1
        JOIN state_translation
        ON "abbreviation" = sub1.state
        JOIN campaign_detail
        ON campaign_detail.filer_id = sub1.filer_id
        );

