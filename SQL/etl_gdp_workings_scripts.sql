SELECT *
FROM etl.countries_gdp;

SELECT *
FROM etl.countries_gdp_update_log;



SELECT *
FROM information_schema.columns
WHERE table_schema = 'etl' and table_name = 'countries_gdp'
ORDER BY ordinal_position;

SELECT proname, pg_get_function_arguments(p.oid)
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'etl' AND proname = 'update_gdp_data';


-----------------------------------------------------------------------------------------	Adding New Columns
																							--| Insert into LOG table FK country_gdp_id
ALTER TABLE etl.countries_gdp_update_log														-- 1 Inserting Column
ADD COLUMN country_gdp_id INTEGER;

ALTER TABLE etl.countries_gdp_update_log														-- 2 Add Constraint
ADD CONSTRAINT fk_countries_gdp
FOREIGN KEY (country_gdp_id)
	REFERENCES etl.countries_gdp (country_gdp_id)
	ON DELETE CASCADE;

																							--| Drop existing composite primary key constraing
ALTER TABLE etl.countries_gdp 
DROP CONSTRAINT countries_gdp_pkey;
																							--| Add the country_gdp_id column as the primary key
ALTER TABLE etl.countries_gdp
ADD COLUMN country_gdp_id SERIAL PRIMARY KEY;

ALTER TABLE etl.countries_gdp
ADD CONSTRAINT country_period_unique UNIQUE(country, period);
																							--| Add the batch_id column as UUID
ALTER TABLE etl.countries_gdp
ADD COLUMN batch_id UUID;
																							--| Drop Tables
DROP TABLE IF EXISTS etl.countries_gdp;
DROP TABLE IF EXISTS etl.countries_gdp_update_log;
