DROP TABLE IF EXISTS Employee;
CREATE TABLE Employee
(
EmpId INT PRIMARY KEY IDENTITY(1,1),
NAME VARCHAR(100),
Skill VARCHAR(100),
Role VARCHAR(100),
IsEmployee bit
)

DROP TABLE IF EXISTS Employee_TrackChanges;
CREATE TABLE Employee_TrackChanges
(
Id INT PRIMARY KEY IDENTITY(1,1),
DATETIMEKey datetime2 DEFAULT GETDATE() NOT NULL,
CommandId tinyint NOT NULL,
CommandName VARCHAR(10) DEFAULT 'INSERT' NOT NULL,
EmpID INT,
Name VARCHAR(100),
Skill VARCHAR(100),
Role VARCHAR(100),
IsEmployee bit
)

-- 1-Insert
-- 2-Update
-- 3-Delete

-- After Insert
GO
CREATE OR ALTER TRIGGER INSERT_TRIG
ON dbo.Employee
AFTER INSERT
AS
BEGIN
	INSERT INTO dbo.Employee_TrackChanges
	SELECT 
	    -- Id - INT
	    GETDATE(), -- DATETIME - datetime2
	    1, -- CommandId - tinyint
		'INSERT', -- CommandName - VARCHAR
	    I.EmpId, -- EmpID - INT
	    I.Name, -- Name - VARCHAR
	    I.Skill, -- Skill - VARCHAR
	    I.Role, -- Role - VARCHAR
	    I.IsEmployee-- IsEmployee - bit
	FROM INSERTED I
END


-- CHECK After Insert
INSERT INTO dbo.Employee
(
    --EmpId - this column value is auto-generated
    NAME,
    Skill,
    Role,
    IsEmployee
)
VALUES
(
    -- EmpId - INT
    'Hello2', -- NAME - VARCHAR
    'world2', -- Skill - VARCHAR
    'Check', -- Role - VARCHAR
    0 -- IsEmployee - bit
)


SELECT * FROM dbo.Employee e;
SELECT * FROM dbo.Employee_TrackChanges etc;


-- After Update
GO
CREATE OR ALTER TRIGGER UPDATE_TRIG
ON dbo.Employee
AFTER UPDATE
AS
BEGIN
	UPDATE dbo.Employee_TrackChanges
	SET
	    DATETIMEKey=GETDATE(), -- DATETIME - datetime2
	    CommandId=2, -- CommandId - tinyint
		CommandName='UPDATE', -- CommandName - VARCHAR
	    EmpID=I.EmpId, -- EmpID - INT
	    Name=I.Name, -- Name - VARCHAR
	    Skill=I.Skill, -- Skill - VARCHAR
	    Role=I.Role, -- Role - VARCHAR
	    IsEmployee=I.IsEmployee-- IsEmployee - bit
	FROM INSERTED I
	INNER JOIN dbo.Employee_TrackChanges TC
	ON I.EmpId = TC.EmpId
	WHERE Id = TC.Id
END


-- CHECK Update Trigger

UPDATE dbo.Employee
SET
    NAME = 'Hello WORLD' -- VARCHAR
WHERE EmpID=1

SELECT * FROM dbo.Employee e;
SELECT * FROM dbo.Employee_TrackChanges etc;

-- After Delete
GO
CREATE OR ALTER TRIGGER DELETE_TRIG
ON dbo.Employee
AFTER DELETE
AS
BEGIN
	UPDATE dbo.Employee_TrackChanges
	SET
	    DATETIMEKey=GETDATE(), -- DATETIME - datetime2
	    CommandId=2, -- CommandId - tinyint
		CommandName='DELETE', -- CommandName - VARCHAR
	    EmpID=I.EmpId, -- EmpID - INT
	    Name=I.Name, -- Name - VARCHAR
	    Skill=I.Skill, -- Skill - VARCHAR
	    Role=I.Role, -- Role - VARCHAR
	    IsEmployee=I.IsEmployee-- IsEmployee - bit
	FROM DELETED I
	INNER JOIN dbo.Employee_TrackChanges TC
	ON I.EmpId = TC.EmpId
	WHERE Id = TC.Id
END

-- Check DELETE Trigger
DELETE FROM dbo.Employee
WHERE EmpId=1;
SELECT * FROM dbo.Employee e;
SELECT * FROM dbo.Employee_TrackChanges etc;



INSERT INTO dbo.Employee
(
    --EmpId - this column value is auto-generated
    NAME,
    Skill,
    Role,
    IsEmployee
)
VALUES
(
    -- EmpId - INT
    'Hello', -- NAME - VARCHAR
    'world', -- Skill - VARCHAR
    'Check', -- Role - VARCHAR
    0 -- IsEmployee - bit
)

DROP TABLE IF EXISTS GetLastUnchangedDate;
CREATE TABLE GetLastUnchangedDate
(
Id INT PRIMARY KEY IDENTITY(1,1),
TableName VARCHAR(100) DEFAULT 'Employee',
LastUpdatedFeedDate datetime2 NOT NULL
)

-- update feeddate
INSERT INTO dbo.GetLastUnchangedDate
(
    --Id - this column value is auto-generated
    TableName,
    LastUpdatedFeedDate
)
VALUES
(
    -- Id - INT
    'Employee', -- TableName - VARCHAR
    GETDATE() -- LastUpdatedFeedDate - datetime2
)


-- Get changes to be pushed to SQL DB
SELECT * FROM dbo.Employee_TrackChanges etc
WHERE etc.DATETIMEKey > 
(
	SELECT TOP 1 glud.LastUpdatedFeedDate FROM dbo.GetLastUnchangedDate glud
	WHERE glud.TableName='Employee'
	ORDER BY glud.LastUpdatedFeedDate
);