/*
SET NOEXEC OFF;
--*/ SET NOEXEC ON;

/*
 * file: 23-wwidw_manual-incremental-load.sql
*/

USE WWIDW_manual;
GO

/* Truncate and load dimension tables from the source database */

TRUNCATE TABLE Staging.Application_Countries;
GO

INSERT INTO Staging.Application_Countries
(
    CountryID,
    CountryName,
    Region,
    Subregion
)
SELECT
	CountryID,
	CountryName,
	Region,
	Subregion
FROM WideWorldImporters.Application.Countries;
GO

TRUNCATE TABLE Staging.Application_StateProvinces;
GO

INSERT INTO Staging.Application_StateProvinces
(
    StateProvinceID,
    StateProvinceCode,
    StateProvinceName,
    CountryID
)
SELECT
	StateProvinceID,
    StateProvinceCode,
    StateProvinceName,
    CountryID
FROM WideWorldImporters.Application.StateProvinces;
GO

TRUNCATE TABLE Staging.Application_Cities;
GO

INSERT INTO Staging.Application_Cities
(
    CityID,
    CityName,
    StateProvinceID
)
SELECT
	CityID,
    CityName,
    StateProvinceID
FROM WideWorldImporters.Application.Cities;
GO

TRUNCATE TABLE Staging.Sales_Customers;
GO

INSERT INTO Staging.Sales_Customers
(
    CustomerID,
    CustomerName,
    DeliveryCityID
)
SELECT
	CustomerID,
    CustomerName,
    DeliveryCityID
FROM WideWorldImporters.Sales.Customers;
GO

/* Incrementally load fact tables from the source database */

TRUNCATE TABLE Staging.Sales_Orders;
GO

INSERT INTO Staging.Sales_Orders
(
    OrderID,
    CustomerID,
    OrderDate
)
SELECT
	OrderID,
    CustomerID,
    OrderDate
FROM WideWorldImporters.Sales.Orders
WHERE OrderDate > DATEADD(dd, -1, CURRENT_TIMESTAMP);
GO

TRUNCATE TABLE Staging.Sales_OrderLines;
GO

INSERT INTO Staging.Sales_OrderLines
(
    OrderLineID,
    OrderID,
    Quantity,
    UnitPrice
)
SELECT
	OL.OrderLineID,
    OL.OrderID,
    OL.Quantity,
    OL.UnitPrice
FROM WideWorldImporters.Sales.OrderLines OL
INNER JOIN WideWorldImporters.Sales.Orders O ON O.OrderID = OL.OrderID
WHERE O.OrderDate > DATEADD(dd, -1, CURRENT_TIMESTAMP);
GO

/* Execute SSIS packages: LoadDimCity.dtsx, LoadDimCustomer.dtsx, LoadFactSalesOrders.dtsx */

/* Check the content of the dimension and fact tables */
SELECT * FROM Dim.City ORDER BY UpdateDttm DESC;
SELECT * FROM Dim.Customer ORDER BY UpdateDttm DESC;
SELECT * FROM Fact.SalesOrders ORDER BY OrderLineKey DESC;
GO

/* Check the audit log */
SELECT * FROM Audit.Package_Control;
GO
