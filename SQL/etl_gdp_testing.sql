-----------------------------------------------------------------------------------------	Update Data for GDP ID 192
DO $$
DECLARE
    batch_id UUID := uuid_generate_v4();
BEGIN
    -- Example update for country GDP ID 192
    CALL etl.update_gdp_data(
        'Tuvalu',          -- country_name
        'Oceania',         -- gdp_region
        2.00,              -- gdp_value (new value to test update)
        '2023-12-31',      -- gdp_period
        batch_id           -- batch_id
    );
	RAISE NOTICE 'Procedure called for Tuvalu with batch ID: %', batch_id;
END $$;


SELECT *
FROM etl.countries_gdp
WHERE country_gdp_id = 192
ORDER by country_gdp_id;

SELECT *
FROM etl.countries_gdp_update_log
WHERE country_gdp_id = 192;
