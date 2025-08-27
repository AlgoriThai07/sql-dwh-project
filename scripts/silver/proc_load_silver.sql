-- =============================================
-- Procedure : silver.load_silver
-- Purpose   : Transform and load CRM & ERP data 
--             from bronze staging tables into
--             curated silver tables.
-- Notes     : 
--   • Truncates silver tables before each load
--   • Applies business rules (cleansing, mapping)
--   • Ensures only latest records (ROW_NUMBER) 
--   • Logs duration of each load step
--   • Error handling via TRY/CATCH
-- =============================================
-- Usage example:
--   EXEC silver.load_silver

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	BEGIN TRY
		DECLARE @start_time_load DATETIME, @end_time_load DATETIME, @start_time DATETIME, @end_time DATETIME;
		SET @start_time_load = GETDATE();

		PRINT('============================');
		PRINT('LOADING SILVER LAYER');
		PRINT('============================');

		PRINT('----------------------------');
		PRINT('LOADING CRM TABLES');
		PRINT('----------------------------');

		SET @start_time = GETDATE();
		PRINT '>> TRUNCATING TABLE: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info;
		PRINT '>> INSERTING DATA TABLE: silver.crm_cust_info';
		INSERT INTO silver.crm_cust_info(
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date
		)
		SELECT 
			cst_id,
			cst_key,
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname) AS cst_lastname,
			CASE
				WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				ELSE 'n/a'
			END AS cst_marital_status,
			CASE
				WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				ELSE 'n/a'
			END AS cst_gndr,
			cst_create_date
		FROM(
			SELECT 
				*,
				ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
			FROM bronze.crm_cust_info
			WHERE cst_id IS NOT NULL
		) t
		WHERE flag_last = 1;
		SET @end_time = GETDATE();
		PRINT ('Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR));

		SET @start_time = GETDATE();
		PRINT '>> TRUNCATING TABLE: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info;
		PRINT '>> INSERTING DATA TABLE: silver.crm_prd_info';
		INSERT INTO silver.crm_prd_info(
			prd_id ,
			cat_id,
			prd_key,
			prd_nm ,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT 
			prd_id,
			REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
			SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
			prd_nm,
			COALESCE(prd_cost, 0) AS prd_cost,
			CASE UPPER(TRIM(prd_line))
				WHEN 'M' THEN 'Mountain'
				WHEN 'R' THEN 'Road'
				WHEN 'S' THEN 'Other Sales'
				WHEN 'T' THEN 'Touring'
				ELSE 'n/a'
			END AS prd_line,
			CAST (prd_start_dt AS DATE) AS prd_start_dt,
			CAST (LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE) AS prd_end_date
		FROM bronze.crm_prd_info;
		SET @end_time = GETDATE();
		PRINT ('Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR));

		SET @start_time = GETDATE();
		PRINT '>> TRUNCATING TABLE: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details;
		PRINT '>> INSERTING DATA TABLE: silver.crm_sales_details';
		INSERT INTO silver.crm_sales_details(
			sls_ord_num ,
			sls_prd_key ,
			sls_cust_id ,
			sls_order_dt ,
			sls_ship_dt,
			sls_due_dt ,
			sls_sales,
			sls_quantity,
			sls_price
		)
		SELECT 
			sls_ord_num ,
			sls_prd_key ,
			sls_cust_id ,
			CASE WHEN sls_order_dt <= 0 OR LEN(sls_order_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
			END AS sls_order_dt,
			CASE WHEN sls_ship_dt <= 0 OR LEN(sls_ship_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
			END AS sls_ship_dt,
			CASE WHEN sls_due_dt <= 0 OR LEN(sls_due_dt) != 8 THEN NULL
				ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
			END AS sls_due_dt,
			CASE WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != ABS(sls_price) * sls_quantity
				THEN ABS(sls_price) * sls_quantity
				ELSE sls_sales
			END AS sls_sales,
			sls_quantity,
			CASE WHEN sls_price <= 0 OR sls_price IS NULL OR sls_price != ABS(sls_sales) / sls_quantity
				THEN ABS(sls_sales) / sls_quantity
				ELSE sls_price
			END AS sls_price
		FROM bronze.crm_sales_details;
		SET @end_time = GETDATE();
		PRINT ('Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR));

		PRINT('----------------------------');
		PRINT('LOADING ERP TABLES');
		PRINT('----------------------------');

		SET @start_time = GETDATE();
		PRINT '>> TRUNCATING TABLE: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12;
		PRINT '>> INSERTING DATA TABLE: silver.erp_cust_az12';
		INSERT INTO silver.erp_cust_az12(
			CID,
			BDATE,
			GEN
		)
		SELECT 
			CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID, 4, LEN(CID))
				ELSE CID
			END AS CID,
			CASE WHEN BDATE > GETDATE() THEN NULL
				ELSE BDATE
			END AS BDATE,
			CASE WHEN UPPER(TRIM(GEN)) IN ('F', 'FEMALE') THEN 'Female'
				WHEN UPPER(TRIM(GEN)) IN ('M', 'MALE') THEN 'Male'
				ELSE 'n/a'
			END AS GEN
		FROM bronze.erp_cust_az12;
		SET @end_time = GETDATE();
		PRINT ('Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR));

		SET @start_time = GETDATE();
		PRINT '>> TRUNCATING TABLE: silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101;
		PRINT '>> INSERTING DATA TABLE: silver.erp_loc_a101';
		INSERT INTO silver.erp_loc_a101(
			CID, CNTRY
		)
		SELECT 
			REPLACE(CID, '-', '') CID,
			CASE WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
				WHEN TRIM(CNTRY) IN ('USA', 'US') THEN 'United States'
				WHEN TRIM(CNTRY) = '' OR CNTRY IS NULL THEN 'n/a'
				ELSE TRIM(CNTRY)
			END AS CNTRY
		FROM bronze.erp_loc_a101;
		SET @end_time = GETDATE();
		PRINT ('Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR));

		SET @start_time = GETDATE();
		PRINT '>> TRUNCATING TABLE: silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2;
		PRINT '>> INSERTING DATA TABLE: silver.erp_px_cat_g1v2';
		INSERT INTO silver.erp_px_cat_g1v2
		(
			ID ,
			CAT ,
			SUBCAT ,
			MAINTENANCE
		)
		SELECT 
			ID ,
			CAT ,
			SUBCAT ,
			MAINTENANCE 
		FROM bronze.erp_px_cat_g1v2;
		SET @end_time = GETDATE();
		PRINT ('Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR));

		SET @end_time_load = GETDATE();
		PRINT('======================');
		PRINT('LOADING SILVER LAYER IS COMPLETE');
		PRINT ('Load silver duration: ' + CAST(DATEDIFF(second, @start_time_load, @end_time_load) AS NVARCHAR));
		PRINT('======================');
	END TRY
	BEGIN CATCH
		PRINT('======================');
		PRINT('ERROR MESSAGE: ' + ERROR_MESSAGE());
		PRINT('ERROR NUMBER: ' + CAST(ERROR_NUMBER() AS NVARCHAR));
		PRINT('ERROR STATE: ' + CAST(ERROR_STATE() AS NVARCHAR));
		PRINT('======================');
	END CATCH
END
