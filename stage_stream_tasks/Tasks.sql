USE ROLE ACCOUNTADMIN;
USE SCHEMA MYDB.MYSCHEMA;

CREATE OR REPLACE TABLE SourceEmployee (
    EmployeeID INT,
    EmployeeName VARCHAR(100),
    Department VARCHAR(100),
    Salary DECIMAL(10,2)
)
DATA_RETENTION_TIME_IN_DAYS = 2;

CREATE TABLE TargetEmployee (
    EmployeeID INT PRIMARY KEY,
    EmployeeName VARCHAR(100),
    Department VARCHAR(100),
    Salary DECIMAL(10,2),
    InsertedDate DATETIME DEFAULT GETDATE(),
    UpdatedDate DATETIME NULL
);

INSERT INTO SourceEmployee
(EmployeeID, EmployeeName, Department, Salary)
VALUES
(1, 'John', 'IT', 50000),
(2, 'Mary', 'HR', 45000),
(3, 'David', 'Finance', 60000);


UPDATE SourceEmployee SET EmployeeName='Rakshith' where
EmployeeID=1


CREATE OR REPLACE TASK TSK_EMPLOYEE
WAREHOUSE = COMPUTE_WH
SCHEDULE = '1 MINUTE'
AS
MERGE INTO MYSCHEMA.TargetEmployee T
USING MYSCHEMA.SourceEmployee S
ON T.EmployeeID = S.EmployeeID

WHEN MATCHED THEN
    UPDATE SET
        T.EmployeeName = S.EmployeeName,
        T.Department   = S.Department,
        T.Salary       = S.Salary,
        T.UpdatedDate  = CURRENT_TIMESTAMP()

WHEN NOT MATCHED THEN
    INSERT (
        EmployeeID,
        EmployeeName,
        Department,
        Salary,
        InsertedDate,
        UpdatedDate
    )
    VALUES (
        S.EmployeeID,
        S.EmployeeName,
        S.Department,
        S.Salary,
        CURRENT_TIMESTAMP(),
        NULL
    );


SELECT * FROM MYSCHEMA.SOURCEEMPLOYEE;
SELECT * FROM MYSCHEMA.TARGETEMPLOYEE;
select * from 

DESC TASK TSK_EMPLOYEE;

ALTER TASK TSK_EMPLOYEE SUSPEND;
SELECT * FROM TABLE ( INFORMATION_SCHEMA.TASK_HISTORY(TASK_NAME =>'TSK_TEST'));


DESC TABLE MYSCHEMA.SOURCEEMPLOYEE;

SELECT *
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'MYSCHEMA'
  AND TABLE_NAME = 'TARGETEMPLOYEE';

ALTER TASK TSK_TEST RESUME

DESC TASK TSK_TEST
  CREATE TASK TSK_TEST
  WAREHOUSE=COMPUTE_WH
  SCHEDULE = '1 MINUTE'
AS
COPY INTO EVENT FROM @s3_product_owners_event_stage;

SELECT * FROM EVENT;

