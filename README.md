# Extract, Transform, and Load Gross Domestic Product from Wikipedia

This repository orchestrates an Extract, Transform, and Load (ETL) process to manage global GDP data from a public source into a PostgreSQL database. It includes scripts for data extraction from the web, transformation to ensure data quality and consistency, and loading into a database for analytics purposes.

## Project Overview

This project is structured into several components, each responsible for different aspects of the ETL process:

<li><b>Python Scripts</b>: Contain all the logic for data extraction, transformation, and loading. These are located in the <code>Python/</code> directory.
<li>SQL Scripts<b></b>: Define the database schema and procedures for data insertion and updates. These scripts are located in the <code>SQL/</code> directory.
<li><b>Configuration Files</b>: Store database connection settings securely. These are found within the <code>Config DB/</code> folder (Hidden for security purposes).

## Components

### Data Extraction

The extraction process involves scraping GDP data from a Wikipedia archive page. This data includes countries GDP figures, associated regions, and corresponding fiscal years.

### Data Transformation

Data transformation involves converting GDP figures from millions to billions for standardization and performing date adjustments to ensure consistency across records.

### Data Loading

The data loading process uses PostgreSQL to manage the data ingestion. This includes checks for existing records to update or insert new data, ensuring data integrity through hash comparisons and managing batch operations for traceability.

## Database Schema

The database schema comprises two main tables:

<li><b>Countries GDP</b>: This table stores the actual GDP data along with metadata like creation and update timestamps.
<li><b>Update Log</b>: This table logs every insert or update operation performed on the GDP data for auditing and traceability purposes.

### Stored Procedures

Stored procedures within the database handle the logic for either inserting new records or updating existing ones based on a computed hash value that reflects the content of the records.
