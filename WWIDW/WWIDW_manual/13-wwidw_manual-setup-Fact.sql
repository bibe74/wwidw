/*
SET NOEXEC OFF;
--*/ SET NOEXEC ON;

/*
 * file: 13-wwidw_manual-setup-Fact.sql
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

/* Fact schema - Data warehouse fact tables */

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = N'Fact')
BEGIN
	EXEC ('CREATE SCHEMA Fact AUTHORIZATION dbo;');

	GRANT SELECT ON SCHEMA :: Fact TO dw_reader;
END;
GO

/* SalesOrders fact table */

IF OBJECT_ID('Fact.SalesOrdersView', 'V') IS NULL EXEC ('CREATE VIEW Fact.SalesOrdersView AS SELECT 1 AS fld;');
GO

ALTER VIEW Fact.SalesOrdersView
AS
SELECT
    T.OrderLineID,
    T.OrderID,
    T.CustomerKey,
    T.OrderDate,
    T.SalesAmount,

	T.HistoricalHashKey,
	T.ChangeHashKey,
	CONVERT(VARCHAR(34), T.HistoricalHashKey, 1) AS HistoricalHashKeyASCII,
	CONVERT(VARCHAR(34), T.ChangeHashKey, 1) AS ChangeHashKeyASCII,
	CURRENT_TIMESTAMP AS InsertDttm,
	CURRENT_TIMESTAMP AS UpdateDttm

FROM (
	SELECT
		O.OrderID,
        --O.CustomerID,
		C.CustomerKey,
        O.OrderDate,
        OL.OrderLineID,
        --OL.OrderID,
        --OL.Quantity,
        --OL.UnitPrice,
		OL.Quantity * OL.UnitPrice AS SalesAmount,
		CONVERT(VARBINARY(20), HASHBYTES('MD5', CONCAT(OL.OrderLineID, ' '))) AS HistoricalHashKey,
		CONVERT(VARBINARY(20), HASHBYTES('MD5', CONCAT(
			O.OrderID,
			C.CustomerKey,
			O.OrderDate,
			OL.Quantity,
			OL.UnitPrice,
			' '
		))) AS ChangeHashKey

	FROM Staging.Sales_Orders O
	INNER JOIN Staging.Sales_OrderLines OL ON OL.OrderID = O.OrderID
	INNER JOIN Dim.Customer C ON C.CustomerID = O.CustomerID
) T;
GO

--DROP TABLE Fact.SalesOrders;
GO

IF OBJECT_ID('Fact.SalesOrders', 'U') IS NULL
BEGIN

	SELECT TOP 0 IDENTITY(BIGINT, 1, 1) AS OrderLineKey, * INTO Fact.SalesOrders FROM Fact.SalesOrdersView;

	ALTER TABLE Fact.SalesOrders ADD CONSTRAINT PK_Fact_SalesOrders PRIMARY KEY CLUSTERED (OrderLineKey);

	--CREATE UNIQUE NONCLUSTERED INDEX IX_Fact_SalesOrders_OrderLineID ON Fact.SalesOrders (OrderLineID);

	ALTER TABLE Fact.SalesOrders ADD CONSTRAINT FK_Fact_SalesOrders_CustomerKey FOREIGN KEY (CustomerKey) REFERENCES Dim.Customer (CustomerKey);

END;
GO

/* Create a new diagram with all the Fact and Dim tables */
