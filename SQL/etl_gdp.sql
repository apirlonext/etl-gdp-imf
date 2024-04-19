-- Table Schema Definition
																						--| Countries GDP (Main Table)
CREATE TABLE IF NOT EXISTS etl.countries_gdp (
    country_gdp_id				SERIAL PRIMARY KEY,
	country             		VARCHAR(50),
    region              		VARCHAR,
    gdp_usd_billions    		FLOAT,
    period              		DATE,
    created_at          		TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at          		TIMESTAMP WITHOUT TIME ZONE DEFAULT NULL,
	data_hash 					VARCHAR(255),
	batch_id					UUID,
    UNIQUE (country, period)
);
																						--| Countries GDP - Update Log (Used to keep tracking changes)
CREATE TABLE IF NOT EXISTS etl.countries_gdp_update_log (
	gpd_update_log_id			SERIAL PRIMARY KEY,
	action_taken				VARCHAR(10),
	gdp_update_log_timestamp	TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
	country						VARCHAR(50),
	period						DATE,
	country_gdp_id				INTEGER,
	batch_id					UUID,
	FOREIGN KEY (country_gdp_id)
		REFERENCES etl.countries_gdp (country_gdp_id)
		ON DELETE CASCADE
);

-- Procedure responsible for inserting new records or updating existing ones based on the provided data
CREATE OR REPLACE PROCEDURE etl.update_gdp_data (
    country_name    VARCHAR,
    gdp_region      VARCHAR,
    gdp_value       FLOAT,
    gdp_period      DATE,
	batch_id		UUID
)

LANGUAGE plpgsql
AS $$

DECLARE
	-- Variable for the hash of the incoming data
	new_hash VARCHAR; 	
	-- Variable to hold existing record data
	existing_record etl.countries_gdp%ROWTYPE; 																
	
BEGIN
	-- Calculate a hash of the incoming data to check against existing records
	new_hash := MD5(country_name || COALESCE(gdp_region, '') || gdp_value::text || gdp_period::text);
	
	-- Retrieve existing record, if any, based on the country and period
	SELECT * INTO existing_record
	FROM etl.countries_gdp
	WHERE country = country_name AND period = gdp_period;
	
	-- If no existing record is found, proceed to insert the new data along with the calculated hash.
	IF existing_record.country_gdp_id IS NULL THEN
		INSERT INTO etl.countries_gdp(country, region, gdp_usd_billions, period, created_at, data_hash, batch_id)
		VALUES(country_name, gdp_region, gdp_value, gdp_period, CURRENT_TIMESTAMP, new_hash, batch_id)
		RETURNING country_gdp_id INTO existing_record.country_gdp_id;
		
		-- Insertion Log
		INSERT INTO etl.countries_gdp_update_log(action_taken, country, period, country_gdp_id, batch_id)
		VALUES ('INSERT', country_name, gdp_period, existing_record.country_gdp_id, batch_id);
		
	-- If an existing record is found and the hash differs, update the record with the new data.	
	ELSEIF new_hash != existing_record.data_hash THEN
		UPDATE etl.countries_gdp
		SET region = gdp_region,
			gdp_usd_billions = gdp_value,
			updated_at = CURRENT_TIMESTAMP,
			data_hash = new_hash,
			batch_id = batch_id
		WHERE country_gdp_id = existing_record.country_gdp_id;
		
		-- Updating Log
		INSERT INTO etl.countries_gdp_update_log(action_taken, country, period, country_gdp_id, batch_id)
		VALUES ('UPDATE', country_name, gdp_period, existing_record.country_gdp_id, batch_id);
		
	END IF;
	-- No ELSE block is needed as no action is required if the hash matches (no data changes).
END;
$$;