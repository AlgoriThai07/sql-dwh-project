-- =============================================
-- Script     : silver_layer_tables.sql
-- Purpose    : Create silver-layer tables for 
--              CRM and ERP domains in the data warehouse
-- Notes      :
--   • Drops existing tables if present
--   • Creates fresh silver tables with transformations-ready schema
--   • Each table includes dwh_create_date for ETL audit
-- Author     : Viet Thai Nguyen
-- Created On : 2025-08-26
-- =============================================

-- ===================================================
-- CRM CUSTOMER INFO (cleansed & deduplicated records)
-- ===================================================
IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_cust_info;
CREATE TABLE silver.crm_cust_info (
    cst_id INT,                         -- Customer surrogate key
    cst_key NVARCHAR(50),               -- Business/customer key
    cst_firstname NVARCHAR(50),         -- First name (trimmed)
    cst_lastname NVARCHAR(50),          -- Last name (trimmed)
    cst_marital_status NVARCHAR(10),    -- Normalized marital status
    cst_gndr NVARCHAR(50),              -- Normalized gender
    cst_create_date DATE,               -- Original create date
    dwh_create_date DATETIME2 DEFAULT GETDATE() -- ETL audit timestamp
);

-- ===================================================
-- CRM PRODUCT INFO (cleansed product master)
-- ===================================================
IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;
CREATE TABLE silver.crm_prd_info (
    prd_id INT,                         -- Product surrogate key
    cat_id NVARCHAR(50),                -- Derived category id
    prd_key NVARCHAR(50),               -- Business/product key
    prd_nm NVARCHAR(50),                -- Product name
    prd_cost INT,                       -- Standard cost (defaults to 0 if null)
    prd_line NVARCHAR(50),              -- Product line (mapped to domain values)
    prd_start_dt DATE,                  -- Valid-from date
    prd_end_dt DATE,                    -- Valid-to date
