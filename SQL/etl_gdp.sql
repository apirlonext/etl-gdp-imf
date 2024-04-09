-- Table Schema Definition
CREATE TABLE IF NOT EXISTS etl.countries_gdp (
    country_gdp_id		SERIAL PRIMARY KEY,
	country             VARCHAR(50),
    region              VARCHAR,
    gdp_usd_billions    FLOAT,
    period              DATE,
    created_at          TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP WITHOUT TIME ZONE DEFAULT NULL,
	data_hash 			VARCHAR(255),
    UNIQUE (country, period)
);
-- Procedure responsible for inserting new records or updating existing ones based on the provided data
CREATE OR REPLACE PROCEDURE etl.update_gdp_data (
    country_name    VARCHAR,
    gdp_region      VARCHAR,
    gdp_value       FLOAT,
    gdp_period      DATE
)

LANGUAGE plpgsql
AS $$

DECLARE
	new_hash VARCHAR; -- Variable for the hash of the incoming data
	existing_record etl.countries_gdp%ROWTYPE; -- Variable to hold existing record data
	
BEGIN
	-- Calculate a hash of the incoming data to check against existing records
	new_hash := MD5(country_name || COALESCE(gdp_region, '') || gdp_value::text || gdp_period::text);
	
	-- Retrieve existing record, if any, based on the country and period
	SELECT * INTO existing_record
	FROM etl.countries_gdp
	WHERE country = country_name and period = gdp_period;
	
	-- If no existing record is found, proceed to insert the new data along with the calculated hash.
	IF existing_record.country_gdp_id IS NULL THEN
		insert into etl.countries_gdp(country, region, gdp_usd_billions, period, created_at, data_hash)
		values(country_name, gdp_region, gdp_value, gdp_period, CURRENT_TIMESTAMP, new_hash);
		
	-- If an existing record is found and the hash differs, update the record with the new data.	
	ELSEIF new_hash != existing_record.data_hash THEN
		update etl.countries_gdp
		set region = gdp_region,
			gdp_usd_billions = gdp_value,
			updated_at = CURRENT_TIMESTAMP,
			data_hash = new_hash
		where country_gdp_id = existing_record.country_gdp_id;
	END IF;
	-- No ELSE block is needed as no action is required if the hash matches (no data changes).
END;
$$;