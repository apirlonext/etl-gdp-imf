SELECT *
FROM etl.countries_gdp;

SELECT *
FROM information_schema.columns
WHERE table_schema = 'etl' and table_name = 'countries_gdp'
ORDER BY ordinal_position;

SELECT proname, pg_get_function_arguments(p.oid)
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'etl' AND proname = 'update_gdp_data';


-----------------------------------------------------------------------------------------	Adding New Columns

																							--| Drop existing composite primary key constraing
ALTER TABLE etl.countries_gdp 
DROP CONSTRAINT countries_gdp_pkey;
																							--| Add the country_gdp_id column as the primary key
ALTER TABLE etl.countries_gdp
ADD COLUMN country_gdp_id SERIAL PRIMARY KEY;
																							--| Add unique constraint for country and period
ALTER TABLE etl.countries_gdp
ADD CONSTRAINT country_period_unique UNIQUE(country, period);



ALTER TABLE etl.countries_gdp
ADD COLUMN country_gdp_id SERIAL PRIMARY KEY;
