# Snowflake Open Catalogue Setup Guide

## Create an Open Catalog account

An Open Catalog account can be created only by an ORGADMIN.

1. In Snowsight, in the navigation pane, select Admin > Accounts.

2. In the + Account drop-down, select Create Snowflake Open Catalog Account.

3. Complete the Create Snowflake Open Catalog Account dialog:
- Cloud: The cloud provider where you want to store Apache Iceberg™ tables.
- Region: The region where you want to store Iceberg tables.
- Edition: The edition for your Open Catalog account.
- Select Next.

4. From the Create New Account dialog, complete the Account Name, User Name, Password, and Email fields.

5. Select Create Account. Your new Open Catalog Account is created and a confirmation box appears.

6. In the confirmation box, select the Account Locator URL to open the Account Locator URL in your web browser.

7. Bookmark the Account Locator URL. When signing in to Open Catalog, you must specify the Account Locator URL.

## Sign in to the Open Catalog web interface
1. Click the account URL that you received via email after creating the account, OR go to https://app.snowflake.com.

2. Click Sign into a different account and sign in with the Open Catalog account created earlier.

## Create an external catalog in Open Catalog
The Iceberg tables from Snowflake can be synchronized in an external catalog in your Open Catalog account.

1. Sign in to your new Open Catalog account.

2. To create a new catalog, in the pane on the left, select Catalogs.

3. Select +Catalog in the upper right.

4. In the Create Catalog dialog, enter the following details:
- Name: Name the catalog demo_catalog_ext.
- Set the toggle for External to On.
- Default base location: s3://hol-iceberg/ffoo/
- Additional locations (optional): A comma separated list of multiple storage locations. It is mainly used if you need to import tables from different locations in this catalog. You can leave it blank.
- S3 role ARN: arn:aws:iam::060795901784:role/snowflake_role
- External ID: (optional): iceberg_table_external_id
- Select Create. 


## Create a connection for Snowflake
1. In Open Catalog, in the left pane, select the Connections tab, and then select + Connection in the upper right.

2. In the Configure Service Connection dialog, create a new principal role or choose from one of the available roles.

3. Select Create.

4. From the Configure Service Connection dialog, to copy the Client ID and Client Secret to a text editor, select Copy inside the As <CLIENT ID>:<SECRET> field.

Important
You won’t be able to retrieve these text strings from the Open Catalog service later, so you must copy them now. You use these text strings when you configure Spark.

## Set up catalog privileges
1. To set up privileges on the external catalog so Snowflake connection has the right privileges for an external catalog, follow these steps:

2. In the navigation pane, select Catalogs, and then select your external catalog in the list.

3. To create a new role, select the Roles tab.

4. Select + Catalog role.

5. In the Create Catalog Role dialog, for Name, enter snowflake_catalog_role.

6. For Privileges, select CATALOG_MANAGE_CONTENT, and then select Create.

7. This gives the role privileges to create, read, and write to tables.

8. Select Grant to Principal Role.

9. In the Grant Catalog Role dialog, for Principal role to receive grant, select the principal role that you created in the previous step

10. For Catalog role to grant, select spark_catalog_role, and then select Grant.

## Paste the worksheet (Optional) Step 5 - Polaris Catalogue Setup.sql into a new snowflake worksheet in Snowsight UI and execute the queries