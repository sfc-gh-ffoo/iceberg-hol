
/************************************* Step 5 - Polaris Catalogue Setup *************************************/

CREATE OR REPLACE CATALOG INTEGRATION demo_open_catalog_ext 
  CATALOG_SOURCE=POLARIS 
  TABLE_FORMAT=ICEBERG 
  CATALOG_NAMESPACE='default' 
  REST_CONFIG = (
    CATALOG_URI ='https://<replace with your account locator>.ap-southeast-1.snowflakecomputing.com/polaris/api/catalog' 
    WAREHOUSE = 'demo_catalog_ext'
  )
  REST_AUTHENTICATION = (
    TYPE=OAUTH 
    OAUTH_CLIENT_ID='<replace with your client_id>' 
    OAUTH_CLIENT_SECRET='<replace with your client_secret>' 
    OAUTH_ALLOWED_SCOPES=('PRINCIPAL_ROLE:ALL') 
  ) 
  ENABLED=true;


--the <catalog_name> created in previous step is demo_catalog_ext.

use database iceberg_lab;
use schema iceberg_lab;
-- Note that the storage location for this external volume will be different than storage location for external volume in use case 1

CREATE OR REPLACE EXTERNAL VOLUME snowflake_demo_ext
  STORAGE_LOCATIONS =
      (
        (
            NAME = 'polaris-hol-s3'
            STORAGE_PROVIDER = 'S3'
            STORAGE_BASE_URL = 's3://hol-iceberg/ffoo/'
            STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::060795901784:role/snowflake_role'
            STORAGE_AWS_EXTERNAL_ID = 'iceberg_table_external_id'
        )
      );

DESC EXTERNAL VOLUME snowflake_demo_ext;

CREATE OR REPLACE ICEBERG TABLE another_customer_iceberg (
    c_custkey INTEGER,
    c_name STRING,
    c_address STRING,
    c_nationkey INTEGER,
    c_phone STRING,
    c_acctbal INTEGER,
    c_mktsegment STRING,
    c_comment STRING
)  
    CATALOG = 'SNOWFLAKE'
    EXTERNAL_VOLUME = 'snowflake_demo_ext'
    BASE_LOCATION = ''
    CATALOG_SYNC = 'demo_open_catalog_ext';

SELECT * FROM another_customer_iceberg;


  