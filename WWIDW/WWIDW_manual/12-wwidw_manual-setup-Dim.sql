/*
SET NOEXEC OFF;
--*/ SET NOEXEC ON;

/*
 * file: 12-wwidw_manual-setup-Dim.sql
*/

USE WWIDW_manual;
GO

IF USER_ID('dw_reader') IS NULL
BEGIN

	CREATE LOGIN dw_reader
	WITH
	  PASSWORD = 'Pa$$w0rd',
	  DEFAULT_DATABASE = WWIDW_manual;

	CREATE USER dw_reader FOR LOGIN dw_reader;

END;
GO

/* Cleanup tables in the right order

DROP TABLE IF EXISTS Dim.Customer;
DROP TABLE IF EXISTS Dim.City;
GO

*/

/* Dim schema - Data warehouse dimension tables */

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = N'Dim')
BEGIN
	EXEC ('CREATE SCHEMA Dim AUTHORIZATION dbo;');
END;
GO

/* City dimension */

IF OBJECT_ID('Dim.CityView', 'V') IS NULL EXEC ('CREATE VIEW Dim.CityView AS SELECT 1 AS fld;');
GO

ALTER VIEW Dim.CityView
AS
SELECT
	T.CityID,
    T.CityName,
    T.StateProvinceCode,
    T.StateProvinceName,
    T.CountryName,
    T.Region,
    T.Subregion,

	T.HistoricalHashKey,
	T.ChangeHashKey,
	CONVERT(VARCHAR(34), T.HistoricalHashKey, 1) AS HistoricalHashKeyASCII,
	CONVERT(VARCHAR(34), T.ChangeHashKey, 1) AS ChangeHashKeyASCII,
	CURRENT_TIMESTAMP AS InsertDttm,
	CURRENT_TIMESTAMP AS UpdateDttm

FROM (
	SELECT
		Ci.CityID,
		Ci.CityName,
		--Ci.StateProvinceID,
		--SP.StateProvinceID,
		SP.StateProvinceCode,
		SP.StateProvinceName,
		--SP.CountryID,
		--Co.CountryID,
		Co.CountryName,
		Co.Region,
		Co.Subregion,
		CONVERT(VARBINARY(20), HASHBYTES('MD5', CONCAT(Ci.CityID, ' '))) AS HistoricalHashKey,
		CONVERT(VARBINARY(20), HASHBYTES('MD5', CONCAT(
			Ci.CityName,
			SP.StateProvinceCode,
			SP.StateProvinceName,
			Co.CountryName,
			Co.Region,
			Co.Subregion,
			' '
		))) AS ChangeHashKey

	FROM Staging.Application_Cities Ci
	INNER JOIN Staging.Application_StateProvinces SP ON SP.StateProvinceID = Ci.StateProvinceID
	INNER JOIN Staging.Application_Countries Co ON Co.CountryID = SP.CountryID

	UNION ALL

	SELECT
		-1 AS CityID,
		N'Unknown' AS CityName,
		N'Unknown' AS StateProvinceCode,
		N'Unknown' AS StateProvinceName,
		N'Unknown' AS CountryName,
		N'Unknown' AS Region,
		N'Unknown' AS Subregion,
		CONVERT(VARBINARY(20), HASHBYTES('MD5', CONCAT(-1, ' '))) AS HistoricalHashKey,
		CONVERT(VARBINARY(20), HASHBYTES('MD5', CONCAT('Unknown', ' ', 'Unknown'))) AS ChangeHashKey
) T;
GO

--DROP TABLE Dim.City;
GO

IF OBJECT_ID('Dim.City', 'U') IS NULL
BEGIN

	SELECT TOP 0 IDENTITY(INT, 1, 1) AS CityKey, * INTO Dim.City FROM Dim.CityView;

	ALTER TABLE Dim.City ADD CONSTRAINT PK_Dim_City PRIMARY KEY CLUSTERED (CityKey);

	ALTER TABLE Dim.City ALTER COLUMN HistoricalHashKey VARBINARY(20) NOT NULL;
	ALTER TABLE Dim.City ALTER COLUMN ChangeHashKey VARBINARY(20) NOT NULL;
	ALTER TABLE Dim.City ALTER COLUMN HistoricalHashKeyASCII VARCHAR(34) NOT NULL;
	ALTER TABLE Dim.City ALTER COLUMN ChangeHashKeyASCII VARCHAR(34) NOT NULL;

	--CREATE UNIQUE NONCLUSTERED INDEX IX_Dim_City_CityID ON Dim.City (CityID);

END;
GO

/* Customer dimension */

IF OBJECT_ID('Dim.CustomerView', 'V') IS NULL EXEC ('CREATE VIEW Dim.CustomerView AS SELECT 1 AS fld;');
GO

ALTER VIEW Dim.CustomerView
AS
SELECT
	T.CustomerID,
    T.CustomerName,
    T.DeliveryCityKey,

	T.HistoricalHashKey,
	T.ChangeHashKey,
	CONVERT(VARCHAR(34), T.HistoricalHashKey, 1) AS HistoricalHashKeyASCII,
	CONVERT(VARCHAR(34), T.ChangeHashKey, 1) AS ChangeHashKeyASCII,
	CURRENT_TIMESTAMP AS InsertDttm,
	CURRENT_TIMESTAMP AS UpdateDttm

FROM (
	SELECT
		C.CustomerID,
		C.CustomerName,
		--C.DeliveryCityID,
		DC.CityKey AS DeliveryCityKey,
		CONVERT(VARBINARY(20), HASHBYTES('MD5', CONCAT(C.CustomerID, ' '))) AS HistoricalHashKey,
		CONVERT(VARBINARY(20), HASHBYTES('MD5', CONCAT(
			C.CustomerName,
			DC.CityKey,
			' '
		))) AS ChangeHashKey

	FROM Staging.Sales_Customers C
	INNER JOIN Dim.City DC ON DC.CityID = C.DeliveryCityID

	UNION ALL

	SELECT
		U.UnknownKey AS CustomerID,
		U.UnknownName AS CustomerName,
		C.CityKey AS DeliveryCityKey,
		CONVERT(VARBINARY(20), HASHBYTES('MD5', CONCAT(U.UnknownKey, ' '))) AS HistoricalHashKey,
		CONVERT(VARBINARY(20), HASHBYTES('MD5', CONCAT(U.UnknownName, ' '))) AS ChangeHashKey
	FROM (
		SELECT
			-1 AS UnknownKey,
			N'Unknown' AS UnknownName
	) U
	INNER JOIN Dim.City C ON C.CityID = U.UnknownKey
) T;
GO

--DROP TABLE Dim.Customer;
GO

IF OBJECT_ID('Dim.Customer', 'U') IS NULL
BEGIN

	SELECT TOP 0 IDENTITY(INT, 1, 1) AS CustomerKey, * INTO Dim.Customer FROM Dim.CustomerView;

	ALTER TABLE Dim.Customer ADD CONSTRAINT PK_Dim_Customer PRIMARY KEY CLUSTERED (CustomerKey);

	ALTER TABLE Dim.Customer ALTER COLUMN HistoricalHashKey VARBINARY(20) NOT NULL;
	ALTER TABLE Dim.Customer ALTER COLUMN ChangeHashKey VARBINARY(20) NOT NULL;
	ALTER TABLE Dim.Customer ALTER COLUMN HistoricalHashKeyASCII VARCHAR(34) NOT NULL;
	ALTER TABLE Dim.Customer ALTER COLUMN ChangeHashKeyASCII VARCHAR(34) NOT NULL;

	ALTER TABLE Dim.Customer ADD CONSTRAINT FK_Dim_Customer_DeliveryCityKey FOREIGN KEY (DeliveryCityKey) REFERENCES Dim.City (CityKey);
END;
GO
