/************************************* Part 4 - Sharing Iceberg Tables *************************************/
USE ROLE accountadmin;
GRANT CREATE ACCOUNT ON ACCOUNT TO ROLE iceberg_lab;
USE ROLE ICEBERG_LAB;

-- Proceed to Snowsight UI > Data Products > Private Sharing > Reader Accounts > + New

-- Create a Secure View
USE ROLE iceberg_lab;
USE DATABASE iceberg_lab;
USE SCHEMA iceberg_lab;

CREATE OR REPLACE SECURE VIEW nation_orders_v AS
SELECT
    nation,
    SUM(order_count) as order_count,
    SUM(total_price) as total_price
FROM nation_orders_iceberg
GROUP BY nation;

-- Grant privilege to iceberg_lab role to create a share
USE ROLE accountadmin;
GRANT CREATE SHARE ON ACCOUNT TO ROLE iceberg_lab;
USE ROLE iceberg_lab;

-- Proceed to Snowsight UI > Data Products > Private Sharing > Share > Create a Direct Share
    -- Select Nation_Orders_V
    -- Choose the Reader Account

-- Login to Reader Account and paste this in a new worksheet
USE ROLE accountadmin;

CREATE OR REPLACE WAREHOUSE iceberg_lab_reader 
    WAREHOUSE_SIZE = XSMALL
    AUTO_SUSPEND = 1
    AUTO_RESUME = 1
    INITIALLY_SUSPENDED = TRUE;

-- In the Reader Account, Go to Data Products > Private Sharing > Look for ICEBERG_LAB_NATION_ORDERS_SHARED_DATA under Direct Shares
    -- Click on <Get Data> on the Shared Data