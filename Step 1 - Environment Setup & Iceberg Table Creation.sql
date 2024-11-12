/******* 00 - ENVIRONMENT SETUP *******/
USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE WAREHOUSE iceberg_lab;
CREATE OR REPLACE ROLE iceberg_lab;
CREATE OR REPLACE DATABASE iceberg_lab;
CREATE OR REPLACE SCHEMA iceberg_lab;

GRANT ALL ON DATABASE iceberg_lab TO ROLE iceberg_lab WITH GRANT OPTION;
GRANT ALL ON SCHEMA iceberg_lab.iceberg_lab TO ROLE iceberg_lab WITH GRANT OPTION;
GRANT ALL ON WAREHOUSE iceberg_lab TO ROLE iceberg_lab WITH GRANT OPTION;
GRANT CREATE NOTEBOOK ON SCHEMA iceberg_lab.iceberg_lab TO ROLE iceberg_lab WITH GRANT OPTION;

GRANT ROLE iceberg_lab TO USER iceberg_lab;


/******* 01 - CREATE EXTERNAL VOLUME *******/
USE ROLE accountadmin;

CREATE OR REPLACE EXTERNAL VOLUME iceberg_lab_vol
   STORAGE_LOCATIONS =
      (
         (
            NAME = 'my-s3-ap-southeast-1'
            STORAGE_PROVIDER = 'S3'
            STORAGE_BASE_URL = 'S3://hol-iceberg/<replace_with_participant_id>/'
            STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::060795901784:role/snowflake_role'
            STORAGE_AWS_EXTERNAL_ID = 'iceberg_table_external_id' -- don't change this
         )
      );

DESC EXTERNAL VOLUME iceberg_external_volume; -- Please copy the value for STORAGE_AWS_IAM_USER_ARN into the google sheet

GRANT ALL ON EXTERNAL VOLUME iceberg_lab_vol TO ROLE iceberg_lab WITH GRANT OPTION;


/******* 02 - CREATE ICEBERG TABLE *******/

USE ROLE iceberg_lab;
USE DATABASE iceberg_lab;
USE SCHEMA iceberg_lab;

CREATE OR REPLACE ICEBERG TABLE customer_iceberg (
    c_custkey INTEGER,
    c_name STRING,
    c_address STRING,
    c_nationkey INTEGER,
    c_phone STRING,
    c_acctbal INTEGER,
    c_mktsegment STRING,
    c_comment STRING
)  
    CATALOG='SNOWFLAKE'
    EXTERNAL_VOLUME='iceberg_lab_vol'
    BASE_LOCATION='';

// Let's preview the data that we will be loading into the iceberg table that we just created
SELECT * FROM snowflake_sample_data.tpch_sf1.customer LIMIT 100;

// Let's insert the data into the customer iceberg table
INSERT INTO customer_iceberg
  SELECT * FROM snowflake_sample_data.tpch_sf1.customer;
