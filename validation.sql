CREATE OR REPLACE FUNCTION validation()
  RETURNS SETOF RECORD AS $$
DECLARE
        rec RECORD;
        temp_row RECORD;
BEGIN

  CREATE TEMPORARY TABLE temp_table (source_system_name TEXT, count_rec INTEGER, bool BOOLEAN) ON COMMIT DROP;

  FOR temp_row IN SELECT * FROM staging.validation
  LOOP

    RAISE NOTICE 'sql: %', temp_row.sql;

    EXECUTE format('INSERT INTO temp_table %s', temp_row.sql);

    IF (SELECT true FROM temp_table WHERE temp_table.bool = false LIMIT 1) THEN
      RAISE NOTICE 'there is a false value';

      SELECT temp_table.source_system_name, temp_table.count_rec, temp_row.name, temp_row.sql
      INTO rec
      FROM temp_table;

      RETURN NEXT rec;

      TRUNCATE temp_table;

    END IF;

  END LOOP;
END; $$
LANGUAGE plpgsql;

-- to run this function.
SELECT * FROM validation() AS x(source_system_name TEXT,
                                count_rec INT,
                                test_name TEXT,
                                original_sql TEXT);
