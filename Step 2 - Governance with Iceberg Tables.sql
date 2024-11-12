/************************************* 01 - GOVERNANCE ON ICEBERG TABLE *************************************/


/************** ROW-LEVEL SECURITY **************/

-- Suppose you need to control row-level access to an Iceberg Table for users having different roles. In this example, let's have a role that can see the US customers and one that only sees the non-US customers.


USE ROLE accountadmin;

-- We will create two roles - tpch_us can see only us records, while tpch_intl can see all records
CREATE OR REPLACE ROLE tpch_us;
GRANT ROLE tpch_us TO USER '<replace with your username>';
CREATE OR REPLACE ROLE tpch_intl;
GRANT ROLE tpch_intl TO USER '<replace with your username>';

USE ROLE iceberg_lab;
USE DATABASE iceberg_lab;
USE SCHEMA iceberg_lab;

-- We will create a row access policy that contains what each role will be able to see
CREATE OR REPLACE ROW ACCESS POLICY rap_nation
AS (nation_key number) RETURNS BOOLEAN ->
  ('TPCH_US' = current_role() and nation_key = 24) OR
  ('TPCH_INTL' = current_role() and nation_key != 24);

-- Apply the row access policy to the customer_iceberg table
ALTER ICEBERG TABLE customer_iceberg
ADD ROW ACCESS POLICY rap_nation ON (c_nationkey);

-- Grant the necessary privileges so that the each role will be able to access the tables
GRANT ALL ON DATABASE iceberg_lab TO ROLE tpch_intl;
GRANT ALL ON SCHEMA iceberg_lab.iceberg_lab TO ROLE tpch_intl;
GRANT ALL ON ICEBERG TABLE iceberg_lab.iceberg_lab.customer_iceberg TO ROLE tpch_intl;
GRANT ALL ON DATABASE iceberg_lab TO ROLE tpch_us;
GRANT ALL ON SCHEMA iceberg_lab.iceberg_lab TO ROLE tpch_us;
GRANT ALL ON ICEBERG TABLE iceberg_lab.iceberg_lab.customer_iceberg TO ROLE tpch_us;
GRANT USAGE ON EXTERNAL VOLUME iceberg_lab_vol TO ROLE tpch_intl;
GRANT USAGE ON EXTERNAL VOLUME iceberg_lab_vol TO ROLE tpch_us;
GRANT USAGE ON WAREHOUSE iceberg_lab TO ROLE tpch_us;
GRANT USAGE ON WAREHOUSE iceberg_lab TO ROLE tpch_intl;

// Let's first test the row access policy with the tpch_intl
USE ROLE tpch_intl;
USE WAREHOUSE iceberg_lab;
SELECT
    count(*)
FROM iceberg_lab.iceberg_lab.customer_iceberg;

// Let's now test the row access policy with the tpch_us
USE ROLE tpch_us;
USE WAREHOUSE iceberg_lab;
SELECT
    count(*)
FROM iceberg_lab.iceberg_lab.customer_iceberg;

/************** COLUMN-LEVEL SECURITY **************/
-- In this case, we want the team of analysts to be able to query the customer table but not see their name(c_name), address (c_address), or phone number(c_phone). 

USE ROLE accountadmin;
CREATE OR REPLACE ROLE tpch_analyst;
GRANT ROLE tpch_analyst TO USER '<replace with your username>';

-- We will now add the additional roles into our row access policy
USE ROLE iceberg_lab;
ALTER ROW ACCESS POLICY rap_nation
SET body ->
  ('TPCH_US' = current_role() and nation_key = 24) or
  ('TPCH_INTL' = current_role() and nation_key != 24) or
  ('TPCH_ANALYST' = current_role()) or 
  ('ICEBERG_LAB' = current_role());

-- Perform the privilege grants to the new role
GRANT ALL ON DATABASE iceberg_lab TO ROLE tpch_analyst;
GRANT ALL ON SCHEMA iceberg_lab.iceberg_lab TO ROLE tpch_analyst;
GRANT ALL ON TABLE iceberg_lab.iceberg_lab.customer_iceberg TO ROLE tpch_analyst;
GRANT USAGE ON WAREHOUSE iceberg_lab TO ROLE tpch_analyst;
GRANT USAGE ON EXTERNAL VOLUME iceberg_lab_vol TO ROLE tpch_analyst;
USE ROLE iceberg_lab;

-- Create the masking policy, the analyst should see only masked data
CREATE OR REPLACE MASKING POLICY pii_mask AS (val string) RETURNS string ->
    CASE
        WHEN 'TPCH_ANALYST' = current_role() THEN '*********'
        ELSE val
    END;

-- Apply the masking policy on the respective columns
ALTER ICEBERG TABLE customer_iceberg MODIFY COLUMN c_name SET MASKING POLICY pii_mask;
ALTER ICEBERG TABLE customer_iceberg MODIFY COLUMN c_address SET MASKING POLICY pii_mask;
ALTER ICEBERG TABLE customer_iceberg MODIFY COLUMN c_phone SET MASKING POLICY pii_mask;

-- Let's test the policy!
USE ROLE tpch_analyst;
SELECT
    *
FROM customer_iceberg;

-- Proceed to the Data >> Governance dashboards in Snowsight to view what we have done
-- Change role to account admin

