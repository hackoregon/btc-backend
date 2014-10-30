DROP TABLE IF EXISTS documentation;
CREATE TABLE documentation (
	title text,
	endpoint_name text,
	txt text
	);

DROP FUNCTION IF EXISTS addDocumentation(titleDat text, endpointDat text, txtDat text);
CREATE FUNCTION addDocumentation(titleDat text, endpointDat text, txtDat text) RETURNS void AS $$
BEGIN
	DELETE FROM documentation WHERE documentation.title = titleDat;
	INSERT INTO documentation VALUES (titleDat, endpointDat, txtDat);

END;
$$ LANGUAGE plpgsql;