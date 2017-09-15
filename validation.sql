CREATE OR REPLACE FUNCTION validation()
  RETURNS text AS $$
DECLARE counter INTEGER;
DECLARE minsid INTEGER;
DECLARE maxsid INTEGER;
DECLARE rec RECORD;
DECLARE stmt varchar;
BEGIN
  SELECT MIN(sid) INTO minsid FROM staging.validation;
  SELECT MAX(sid) INTO maxsid FROM staging.validation;

  CREATE TEMPORARY TABLE temp_table (col1 TEXT, col2 INTEGER, col3 BOOLEAN) ON COMMIT DROP;

  FOR counter IN minsid..maxsid LOOP
    RAISE NOTICE 'Counter: %', counter;
    SELECT sql INTO stmt FROM staging.validation WHERE sid = counter;

    RAISE NOTICE 'sql: %', stmt;

    PERFORM 'INSERT INTO temp_table (col1, col2, col3) ' || stmt;

    IF temp_table.col3 = false THEN
      RAISE NOTICE 'there is a false value';
    END IF;

  END LOOP;
END; $$
LANGUAGE plpgsql;
