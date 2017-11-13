/*
SET NOEXEC OFF;
--*/ SET NOEXEC ON;

/*
 * file: 11-wwidw-setup-Setup.sql
*/

USE WWIDW;
GO

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = N'Setup')
BEGIN
	EXEC ('CREATE SCHEMA Setup AUTHORIZATION dbo;'); -- Setup: setup tables
END;
GO

DROP TABLE IF EXISTS Setup.SourceColumns;
DROP TABLE IF EXISTS Setup.SourceTables;
DROP TABLE IF EXISTS Setup.SourceDatabases;
GO

IF OBJECT_ID(N'Setup.SourceDatabases', N'U') IS NOT NULL
BEGIN
	DROP TABLE Setup.SourceDatabases;
END;
GO

CREATE TABLE Setup.SourceDatabases (
	SourceDatabaseID TINYINT NOT NULL IDENTITY (1, 1) CONSTRAINT PK_Setup_SourceDatabases PRIMARY KEY CLUSTERED,
	SourceInstance NVARCHAR(40) NOT NULL,
	SourceDatabase sysname NOT NULL,
	SourceConnectionName NVARCHAR(40) NOT NULL,
	SourceConnectionString NVARCHAR(255) NOT NULL,
	DestinationDatabase sysname NOT NULL,
	DestinationConnectionName NVARCHAR(40) NOT NULL,
	DestinationConnectionString NVARCHAR(255) NOT NULL,
	DestinationLandingSchema sysname NOT NULL
);
GO

INSERT INTO Setup.SourceDatabases
(
    SourceInstance,
    SourceDatabase,
	SourceConnectionName,
	SourceConnectionString,
	DestinationDatabase,
	DestinationConnectionName,
	DestinationConnectionString,
    DestinationLandingSchema
)
SELECT
	N'(local)\SQL2017',
	N'WideWorldImporters',
	N'WideWorldImporters',
	N'Data Source=(local)\SQL2017;Initial Catalog=WideWorldImporters;Provider=SQLNCLI11.1;Integrated Security=SSPI;Auto Translate=False;',
	N'WWIDW',
	N'WWIDW',
	N'Data Source=(local)\SQL2017;Initial Catalog=WWIDW;Provider=SQLNCLI11.1;Integrated Security=SSPI;Auto Translate=False;',
	N'Staging';
GO

IF OBJECT_ID(N'Setup.SourceTables', N'U') IS NOT NULL
BEGIN
	DROP TABLE Setup.SourceTables;
END;
GO

CREATE TABLE Setup.SourceTables (
	SourceTableID INT NOT NULL IDENTITY (1, 1) CONSTRAINT PK_Setup_SourceTables PRIMARY KEY CLUSTERED,
	SourceDatabaseID TINYINT NOT NULL CONSTRAINT FK_Setup_SourceTables_SourceDatabaseID FOREIGN KEY REFERENCES Setup.SourceDatabases (SourceDatabaseID),
	SourceSchema sysname NOT NULL,
	SourceTable sysname NOT NULL,
	UseForDataWarehouse BIT NOT NULL CONSTRAINT DFT_Setup_SourceTables_UseForDataWarehouse DEFAULT (0),
	PublishToDataWarehouse BIT NOT NULL CONSTRAINT DFT_Setup_SourceTables_PublishToDataWarehouse DEFAULT (0),
	DataWarehouseSchema sysname NOT NULL CONSTRAINT DFT_Setup_SourceTables_DataWarehouseSchema DEFAULT (N''),
	DataWarehouseTable sysname NOT NULL CONSTRAINT DFT_Setup_SourceTables_DataWarehouseTable DEFAULT (N'')
);
GO

INSERT INTO Setup.SourceTables
(
    SourceDatabaseID,
    SourceSchema,
    SourceTable
)
SELECT
	(SELECT SourceDatabaseID FROM Setup.SourceDatabases WHERE SourceDatabase = N'WideWorldImporters'),
	S.name,
	T.name

FROM WideWorldImporters.sys.tables T
INNER JOIN WideWorldImporters.sys.schemas S ON S.schema_id = T.schema_id
ORDER BY S.name,
	T.name;
GO

IF OBJECT_ID(N'Setup.SourceColumns', N'U') IS NOT NULL
BEGIN
	DROP TABLE Setup.SourceColumns;
END;
GO

CREATE TABLE Setup.SourceColumns (
	SourceColumnID INT NOT NULL IDENTITY (1, 1) CONSTRAINT PK_Setup_SourceColumns PRIMARY KEY CLUSTERED,
	SourceTableID INT NOT NULL CONSTRAINT FK_Setup_SourceColumns_SourceTableID FOREIGN KEY REFERENCES Setup.SourceTables (SourceTableID),
	SourceSchema sysname NOT NULL,
	SourceTable sysname NOT NULL,
	SourceColumn sysname NOT NULL,
	UseForDataWarehouse BIT NOT NULL CONSTRAINT DFT_Setup_SourceColumns_UseForDataWarehouse DEFAULT (0),
	IsPrimaryKey BIT NOT NULL CONSTRAINT DFT_Setup_SourceColumns_IsPrimaryKey DEFAULT (0),
	PublishToDataWarehouse BIT NOT NULL CONSTRAINT DFT_Setup_SourceColumns_PublishToDataWarehouse DEFAULT (0),
	DataWarehouseSchema sysname NOT NULL CONSTRAINT DFT_Setup_SourceColumns_DataWarehouseSchema DEFAULT (N''),
	DataWarehouseTable sysname NOT NULL CONSTRAINT DFT_Setup_SourceColumns_DataWarehouseTable DEFAULT (N''),
	DataWarehouseColumn sysname NOT NULL CONSTRAINT DFT_Setup_SourceColumns_DataWarehouseColumn DEFAULT (N'')
);
GO

INSERT INTO Setup.SourceColumns
(
    SourceTableID,
	SourceSchema,
	SourceTable,
    SourceColumn
)
SELECT
	ST.SourceTableID,
	ST.SourceSchema,
	ST.SourceTable,
	C.name AS SourceColumn

FROM WideWorldImporters.sys.columns C
INNER JOIN WideWorldImporters.sys.tables T ON T.object_id = C.object_id
INNER JOIN WideWorldImporters.sys.schemas S ON S.schema_id = T.schema_id
INNER JOIN Setup.SourceTables ST ON ST.SourceDatabaseID = 1 AND ST.SourceSchema = S.name AND ST.SourceTable = T.name
ORDER BY S.name,
	T.name,
	C.column_id;
GO

UPDATE Setup.SourceTables
SET UseForDataWarehouse = 1
WHERE SourceDatabaseID = 1
	 AND SourceSchema = N'Sales'
	 AND SourceTable IN (
		N'OrderLines',
		N'Orders',
		N'Customers'
	 );
GO

UPDATE Setup.SourceTables
SET UseForDataWarehouse = 1
WHERE SourceDatabaseID = 1
	 AND SourceSchema = N'Application'
	 AND SourceTable IN (
		N'Cities',
		N'StateProvinces',
		N'Countries'
	 );
GO

UPDATE Setup.SourceTables
SET PublishToDataWarehouse = 1,
	DataWarehouseSchema = N'Fact',
	DataWarehouseTable = N'SalesOrders'
WHERE SourceDatabaseID = 1
	AND SourceSchema = N'Sales'
	AND SourceTable = N'OrderLines';
GO

UPDATE Setup.SourceTables
SET PublishToDataWarehouse = 1,
	DataWarehouseSchema = N'Dim',
	DataWarehouseTable = N'Customer'
WHERE SourceDatabaseID = 1
	AND SourceSchema = N'Sales'
	AND SourceTable = N'Customers';
GO

UPDATE Setup.SourceTables
SET PublishToDataWarehouse = 1,
	DataWarehouseSchema = N'Dim',
	DataWarehouseTable = N'City'
WHERE SourceDatabaseID = 1
	AND SourceSchema = N'Application'
	AND SourceTable = N'Cities';
GO

UPDATE SC
SET SC.IsPrimaryKey = 1

FROM WideWorldImporters.sys.tables T
INNER JOIN WideWorldImporters.sys.schemas S ON S.schema_id = T.schema_id
INNER JOIN WideWorldImporters.sys.indexes I ON I.object_id = T.object_id AND I.is_primary_key = 1
INNER JOIN WideWorldImporters.sys.index_columns IC ON IC.object_id = I.object_id AND IC.index_id = I.index_id
INNER JOIN WideWorldImporters.sys.columns C ON C.object_id = T.object_id AND C.column_id = IC.column_id
INNER JOIN Setup.SourceTables ST ON ST.SourceSchema = S.name AND ST.SourceTable = T.name
INNER JOIN Setup.SourceColumns SC ON SC.SourceTableID = ST.SourceTableID AND SC.SourceColumn = C.name;
GO

UPDATE SC
SET SC.UseForDataWarehouse = 1
FROM Setup.SourceTables ST
INNER JOIN Setup.SourceColumns SC ON SC.SourceTableID = ST.SourceTableID
WHERE 
	(SC.SourceSchema = N'Sales' AND SC.SourceTable = N'OrderLines' AND SC.SourceColumn IN (N'OrderLineID', N'OrderID', N'Quantity', N'UnitPrice'))
	OR (SC.SourceSchema = N'Sales' AND SC.SourceTable = N'Orders' AND SC.SourceColumn IN (N'OrderID', N'CustomerID', N'OrderDate'))
	OR (SC.SourceSchema = N'Sales' AND SC.SourceTable = N'Customers' AND SC.SourceColumn IN (N'CustomerID', N'CustomerName', N'DeliveryCityID'))
	OR (SC.SourceSchema = N'Application' AND SC.SourceTable = N'Cities' AND SC.SourceColumn IN (N'CityID', N'CityName', N'StateProvinceID'))
	OR (SC.SourceSchema = N'Application' AND SC.SourceTable = N'StateProvinces' AND SC.SourceColumn IN (N'StateProvinceID', N'StateProvinceName', N'CountryID'))
	OR (SC.SourceSchema = N'Application' AND SC.SourceTable = N'Countries' AND SC.SourceColumn IN (N'CountryID', N'CountryName', N'Region', N'Subregion'))
;
GO

SELECT
	*
FROM Setup.SourceTables ST

WHERE ST.UseForDataWarehouse = 1
