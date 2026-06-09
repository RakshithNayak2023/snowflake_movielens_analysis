CREATE STORAGE INTEGRATION s3_storage_integration
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::334360387642:role/snowrole'
  STORAGE_ALLOWED_LOCATIONS = ('s3://amzn-snow-bucket01/');

  DESC INTEGRATION s3_storage_integration

  CREATE OR REPLACE STAGE s3_users_stage
  URL = 's3://amzn-snow-bucket01/users/'
  STORAGE_INTEGRATION = s3_storage_integration;



list @s3_users_stage


COPY INTO MYSCHEMA.USERS
FROM @s3_users_stage
FILE_FORMAT=JSON_FILE_FORMAT



SELECT * FROM MYSCHEMA.USERS


CREATE OR REPLACE FILE FORMAT json_file_format
TYPE = JSON;

CREATE FORMAT csv_file_formats
    FIELD_DELIMITER = ','
    RECORD_DELIMITER = '\n'
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    NULL_IF = ('\\N')
    TRIM_SPACE = TRUE;

================================================================================
USE ROLE ACCOUNTADMIN;
USE SCHEMA MYDB.MYSCHEMA;

CREATE OR REPLACE MYSCHEMA.TABLE EVENT(
EVENT VARIANT
);

CREATE OR REPLACE STAGE s3_events_stage
URL='s3://amzn-snow-bucket01/events/'
STORAGE_INTEGRATION = s3_storage_integration;

ALTER STAGE s3_events_stage
SET FILE_FORMAT = JSON_FILE_FORMAT;

CREATE OR REPLACE PIPE s3_events_pipe
auto_ingest=TRUE AS
COPY INTO MYSCHEMA.EVENT
FROM @s3_events_stage
FILE_FORMAT=(FORMAT_NAME=JSON_FILE_FORMAT);



SELECT SYSTEM$PIPE_STATUS('s3_events_pipe');


alter PIPE s3_events_pipe REFRESH

ALTER PIPE s3_events_pipe SET PIPE_EXECUTION_PAUSED=TRUE;

select * from EVENT

SELECT SYSTEM$PIPE_STATUS('s3_events_pipe');
desc PIPE s3_events_pipe;


SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.PIPE_USAGE_HISTORY
WHERE PIPE_NAME = 'S3_EVENTS_PIPE'
ORDER BY START_TIME DESC;

SELECT * FROM MYSCHEMA.EVENT;

select * from directory(@s3_events_stage)

CREATE OR REPLACE TABLE user_events
WITH LOCATION = @s3_events_stage
FILE_FORMAT = (FORMAT_NAME = JSON_FILE_FORMAT)
AS
SELECT
    $1 AS raw_json,
    METADATA$FILENAME AS file_name
FROM @s3_events_stage (FILE_FORMAT=(FORMAT_NAME=JSON_FILE_FORMAT);

SELECT *
FROM @s3_events_stage;

==========================================================


CREATE OR REPLACE STORAGE INTEGRATION S3_PRODUCT_OWNERS_INTEGRATION
TYPE = EXTERNAL_STAGE
STORAGE_PROVIDER='S3'
ENABLED=TRUE
STORAGE_AWS_ROLE_ARN='arn:aws:iam::334360387642:role/snow_prod_owners'
STORAGE_ALLOWED_LOCATIONS=('s3://amzn-s3-product-owners/')

desc STORAGE INTEGRATION S3_PRODUCT_OWNERS_INTEGRATION

create stage s3_product_owners_event_stage 
storage_integration=S3_PRODUCT_OWNERS_INTEGRATION
URL='s3://amzn-s3-product-owners/events'

ls @s3_product_owners_event_stage

SELECT *
FROM directory(@s3_product_owners_event_stage);

ALTER STAGE s3_product_owners_event_stage
SET DIRECTORY = (ENABLE = TRUE);

 SHOW STAGES s3_product_owners_event_stage
ALTER STAGE s3_product_owners_event_stage REFRESH;




CREATE OR REPLACE PIPE S3_PRODUCT_OWNERS_PIPE
AUTO_INGEST = TRUE
AS
COPY INTO EVENT
FROM @s3_product_owners_event_stage
FILE_FORMAT = (FORMAT_NAME = JSON_FILE_FORMAT);

SHOW PIPES LIKE 'S3_PRODUCT_OWNERS_PIPE';

SELECT * FROM EVENT

SELECT SYSTEM$PIPE_STATUS('S3_PRODUCT_OWNERS_PIPE');


ALTER PIPE S3_PRODUCT_OWNERS_PIPE REFRESH
ALTER PIPE S3_PRODUCT_OWNERS_PIPE SET PIPE_EXECUTION_PAUSED = TRUE;

SELECT *
FROM TABLE(INFORMATION_SCHEMA.PIPE_USAGE_HISTORY(
    PIPE_NAME => 'S3_PRODUCT_OWNERS_PIPE'
));



SELECT *
FROM TABLE(INFORMATION_SCHEMA.COPY_HISTORY(
  TABLE_NAME => 'EVENT',
  START_TIME => DATEADD('hour', -2, CURRENT_TIMESTAMP())
))


select * from event;


SELECT f.key, f.value,
f.index	,
f.path,
f.seq
FROM event r,
LATERAL FLATTEN(input => r.event) f;


SELECT
    $1:event_id::NUMBER AS event_id,
    $1:event_name::STRING AS event_name,
    $1:product_id::STRING AS product_id,
    $1:timestamp::STRING AS timestamp,
    $1:user_id::STRING AS user_id
FROM @s3_product_owners_event_stage
(FILE_FORMAT => (TYPE => 'JSON', STRIP_OUTER_ARRAY => TRUE));




