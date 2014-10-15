DROP TABLE IF EXISTS documentation;
CREATE TABLE documentation (
	title varchar(100),
	endpoint_name varchar(100),
	txt text
	);

DROP FUNCTION IF EXISTS addDocumentation(titleDat text, endpointDat text, txtDat text);
CREATE FUNCTION addDocumentation(titleDat text, endpointDat text, txtDat text) RETURNS void AS $$
BEGIN
	DELETE FROM documentation WHERE documentation.title = titleDat;
	INSERT INTO documentation VALUES (titleDat, endpointDat, txtDat);

END;
$$ LANGUAGE plpgsql;