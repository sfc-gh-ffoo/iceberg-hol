USE DATABASE ICEBERG_LAB;

// Only needed if using private bucket, for lab purposes access is temp set to public

/*CREATE STORAGE INTEGRATION MY_STORAGE_INTEGRATION
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = S3
    STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::060795901784:role/storage_integration_snowflake'
    ENABLED = true
    STORAGE_ALLOWED_LOCATIONS = ('*');

DESC STORAGE INTEGRATION MY_STORAGE_INTEGRATION;*/

//To tell snowflake how to ingest the CSV format
CREATE OR REPLACE FILE FORMAT my_csv_format
    TYPE = CSV
    COMPRESSION = NONE
    FIELD_DELIMITER = ','
    RECORD_DELIMITER = '\n'
    SKIP_HEADER = 0
    PARSE_HEADER = TRUE
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    DATE_FORMAT = 'AUTO'
    TIMESTAMP_FORMAT = 'AUTO';

//To tell snowflake where to find the files in the external bucket
CREATE OR REPLACE STAGE MY_EXTERNAL_STAGE
  URL = 's3://hol-csv'
  //STORAGE_INTEGRATION = MY_STORAGE_INTEGRATION
  FILE_FORMAT = MY_CSV_FORMAT;

//List the files
LS @ICEBERG_LAB.PUBLIC.MY_EXTERNAL_STAGE;


//GENERATE COLUMN DESCRIPTIONS FOR E-WALLET CUSTOMER TABLE
SELECT GENERATE_COLUMN_DESCRIPTION(ARRAY_AGG(OBJECT_CONSTRUCT(*)), 'table') AS COLUMNS
  FROM TABLE (
    INFER_SCHEMA(
      LOCATION=>'@ICEBERG_LAB.PUBLIC.MY_EXTERNAL_STAGE/ewallet_customers.csv',
      FILE_FORMAT=>'my_csv_format'
    )
  );

  //CREATE ICEBERG TABLES
  CREATE OR REPLACE ICEBERG TABLE ewallet_customers (
    "customer_id" TEXT,
    "name" TEXT,
    "id_type" TEXT,
    "id_value" NUMBER(12, 0),
    "dob" DATE,
    "age" NUMBER(2, 0),
    "gender" TEXT,
    "email" TEXT,
    "phone" NUMBER(11, 0),
    "city" TEXT,
    "postcode" NUMBER(5, 0),
    "state" TEXT,
    "occupation" TEXT,
    "date_created" TIMESTAMP_NTZ,
    "date_modified" TIMESTAMP_NTZ
)  
    CATALOG='SNOWFLAKE'
    EXTERNAL_VOLUME='iceberg_lab_vol'
    BASE_LOCATION='';

-- Let's copy the data into the ewallet iceberg table
COPY INTO ewallet_customers
  FROM @ICEBERG_LAB.PUBLIC.MY_EXTERNAL_STAGE/ewallet_customers.csv
  FILE_FORMAT = 'my_csv_format'
  LOAD_MODE = FULL_INGEST
  PURGE = TRUE
  MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

SELECT * FROM ewallet_customers LIMIT 100;


// Now let's do the same for ewallet transactions table
//GENERATE COLUMN DESCRIPTIONS FOR E-WALLET CUSTOMER TABLE
SELECT GENERATE_COLUMN_DESCRIPTION(ARRAY_AGG(OBJECT_CONSTRUCT(*)), 'table') AS COLUMNS
  FROM TABLE (
    INFER_SCHEMA(
      LOCATION=>'@ICEBERG_LAB.PUBLIC.MY_EXTERNAL_STAGE/ewallet_transactions.csv',
      FILE_FORMAT=>'my_csv_format'
    )
  );

  //CREATE ICEBERG TABLES
  CREATE OR REPLACE ICEBERG TABLE ewallet_transactions (
    "transaction_id" TEXT,
    "customer_id" TEXT,
    "id_value" NUMBER(12, 0),
    "transaction_date" DATE,
    "merchant" TEXT,
    "category" TEXT,
    "amount" NUMBER(5, 2)
)  
    CATALOG='SNOWFLAKE'
    EXTERNAL_VOLUME='iceberg_lab_vol'
    BASE_LOCATION='';


-- Let's copy the data into the ewallet iceberg table
COPY INTO ewallet_transactions
  FROM @ICEBERG_LAB.PUBLIC.MY_EXTERNAL_STAGE/ewallet_transactions.csv
  FILE_FORMAT = 'my_csv_format'
  LOAD_MODE = FULL_INGEST
  PURGE = TRUE
  MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

SELECT * FROM ewallet_transactions LIMIT 100;

// TODO: Create view on top of the iceberg tables
