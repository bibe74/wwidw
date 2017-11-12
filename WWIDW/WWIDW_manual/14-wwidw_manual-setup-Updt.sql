/*
SET NOEXEC OFF;
--*/ SET NOEXEC ON;

/*
 * file: 14-wwidw_manual-setup-Updt.sql
*/

USE WWIDW_manual;
GO

/* Updt schema - Data warehouse dimension tables' updates */

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = N'Updt')
BEGIN
	EXEC ('CREATE SCHEMA Updt AUTHORIZATION dbo;');
END;
GO

/* Table Updt.UpdtCity: updates to Dim.City */

--DROP TABLE Updt.UpdtCity;
GO

IF OBJECT_ID('Updt.UpdtCity', 'U') IS NULL
BEGIN

	SELECT TOP 0
		--CityKey,
        CityID,
        HistoricalHashKey,
        ChangeHashKey,
        CityName,
        StateProvinceCode,
        StateProvinceName,
        CountryName,
        Region,
        Subregion,
		InsertDttm

	INTO Updt.UpdtCity
	FROM Dim.City;
END;
GO

/* Table Updt.UpdtCustomer: updates to Dim.Customer */

--DROP TABLE Updt.UpdtCustomer;
GO

IF OBJECT_ID('Updt.UpdtCustomer', 'U') IS NULL
BEGIN

	SELECT TOP 0
		--CustomerKey,
        CustomerID,
        HistoricalHashKey,
        ChangeHashKey,
        CustomerName,
        DeliveryCityKey,
		InsertDttm

	INTO Updt.UpdtCustomer
	FROM Dim.Customer;
END;
GO
