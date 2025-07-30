/*
================================
Create Database and Schemas
================================
Script purpose:
This script create a new database named 'DataWarehouse' after checking if it exists.
If the database exists, it is dropped and recreated. Additionally, this script creates
3 schemas within the db: 'bronze', 'silver', and 'gold'

Warning:
	Running this will drop the entire 'DataWarehouse' database if it exists
	All data will be permanently deleted. Proceed with caution and ensure you have
	proper backups before running this script.
*/

USE master;
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse
END;
GO

CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
