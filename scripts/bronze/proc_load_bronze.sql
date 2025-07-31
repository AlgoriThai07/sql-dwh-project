-- =============================================
-- Procedure : bronze.load_bronze
-- Purpose   : Load CRM and ERP CSV files into bronze staging tables using BULK INSERT
-- Notes     : Truncates tables before load, logs duration, handles errors via TRY/CATCH
-- =============================================
-- Usage example
  -- EXEC bronze.load_bronze
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME;
	BEGIN TRY
		PRINT('============================');
		PRINT('LOADING BRONZE LAYER');
		PRINT('============================');

		PRINT('----------------------------');
		PRINT('LOADING CRM TABLES');
		PRINT('----------------------------');

		PRINT('LOADING crm_cust_info');
		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.crm_cust_info;

		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\thai0\OneDrive\Documents\Coding\SQL\Data_Warehouse_Project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT('LOAD DURATION: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR));

		PRINT('LOADING crm_prd_info');
		SET @start_time = GETDATE();
		TRUNCATE TABLE bronze.crm_prd_info;

		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\thai0\OneDrive\Documents\Coding\SQL\Data_Warehouse_Project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT('LOAD DURATION: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR));
		
		PRINT('LOADING crm_sales_details');
		SET @start_time = GETDATE();

		TRUNCATE TABLE bronze.crm_sales_details;

		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\thai0\OneDrive\Documents\Coding\SQL\Data_Warehouse_Project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT('LOAD DURATION: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR));

		PRINT('----------------------------');
		PRINT('LOADING ERP TABLES');
		PRINT('----------------------------');

		PRINT('LOADING erp_cust_az12');
		SET @start_time = GETDATE();

		TRUNCATE TABLE bronze.erp_cust_az12;

		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\thai0\OneDrive\Documents\Coding\SQL\Data_Warehouse_Project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT('LOAD DURATION: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR));

		PRINT('LOADING erp_loc_a101');
		SET @start_time = GETDATE();

		TRUNCATE TABLE bronze.erp_loc_a101;

		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\thai0\OneDrive\Documents\Coding\SQL\Data_Warehouse_Project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT('LOAD DURATION: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR));

		PRINT('LOADING erp_px_cat_g1v2');
		SET @start_time = GETDATE();

		TRUNCATE TABLE bronze.erp_px_cat_g1v2;

		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\thai0\OneDrive\Documents\Coding\SQL\Data_Warehouse_Project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT('LOAD DURATION: ' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR));
	END TRY
	BEGIN CATCH
		PRINT('======================');
		PRINT('ERROR MESSAGE: ' + ERROR_MESSAGE());
		PRINT('ERROR MESSAGE: ' + CAST (ERROR_NUMBER() AS NVARCHAR));
		PRINT('ERROR MESSAGE: ' + CAST (ERROR_STATE() AS NVARCHAR));
		PRINT('======================');
	END CATCH
END
