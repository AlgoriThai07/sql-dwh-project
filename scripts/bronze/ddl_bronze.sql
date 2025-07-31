/******************************************************************************************
-- Description : Script to drop and create staging tables (bronze layer) for CRM and ERP data
--               including customer info, product info, sales details, and master data.
-- Environment : [e.g., Development / QA / Production]
-- Notes       : 
--   - Ensures existing tables are dropped before creation to avoid conflicts.
--   - Assumes schema `bronze` already exists.
--   - Used for ETL or data pipeline ingestion preparation.
******************************************************************************************/

-- Drop and create CRM customer information table
IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
	DROP TABLE bronze.crm_cust_info;
CREATE TABLE bronze.crm_cust_info (
	cst_id INT,                          -- Unique customer ID
	cst_key NVARCHAR(50),                -- Business key
	cst_firstname NVARCHAR(50),         -- First name
	cst_lastname NVARCHAR(50),          -- Last name
	cst_marital_status NVARCHAR(10),    -- Marital status (e.g., Single, Married)
	cst_gndr NVARCHAR(50),              -- Gender
	cst_create_date DATE                -- Record creation date
);

-- Drop and create CRM product information table
IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
	DROP TABLE bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info (
	prd_id INT,                          -- Unique product ID
	prd_key NVARCHAR(50),                -- Business product key
	prd_nm NVARCHAR(50),                 -- Product name
	prd_cost INT,                        -- Product cost
	prd_line NVARCHAR(50),              -- Product line/category
	prd_start_dt DATETIME,              -- Start availability date
	prd_end_dt DATETIME                 -- End availability date
);

-- Drop and create CRM sales details table
IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
	DROP TABLE bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details (
	sls_ord_num NVARCHAR(50),           -- Sales order number
	sls_prd_key NVARCHAR(50),           -- Product key
	sls_cust_id INT,                    -- Customer ID (foreign key to crm_cust_info)
	sls_order_dt INT,                   -- Order date (as INT, likely YYYYMMDD)
	sls_ship_dt INT,                    -- Shipment date
	sls_due_dt INT,                     -- Due date
	sls_sales INT,                      --_
