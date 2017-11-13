/*
SET NOEXEC OFF;
--*/ SET NOEXEC ON;

/*
 * file: 21-wwidw_manual-initial-load.sql
*/

USE WWIDW_manual;
GO

/* Cleanup fact, dimensions, staging and audit tables

TRUNCATE TABLE Fact.SalesOrders;
DELETE FROM Dim.Customer;
DELETE FROM Dim.City;
GO

TRUNCATE TABLE Staging.Application_Cities;
TRUNCATE TABLE Staging.Application_Countries;
TRUNCATE TABLE Staging.Application_StateProvinces;
TRUNCATE TABLE Staging.Sales_Customers;
TRUNCATE TABLE Staging.Sales_OrderLines;
TRUNCATE TABLE Staging.Sales_Orders;
GO

TRUNCATE TABLE Audit.Package_Control;
GO

*/

/* Check the content of the dimension tables */
SELECT * FROM Dim.City;
SELECT * FROM Dim.Customer;
GO

/* Generate SSIS packages from: 01-CreateDimCity.biml, 02-CreateDimCustomer.biml, 11-CreateFactSalesOrders.biml */

/* Execute SSIS packages: 01-LoadDimCity.dtsx, 02-LoadDimCustomer.dtsx, 11-LoadFactSalesOrders.dtsx */

/* Check the content of the dimension tables */
SELECT * FROM Dim.City;
SELECT * FROM Dim.Customer;
GO

/* Check the content of the fact table */
SELECT * FROM Fact.SalesOrders;
GO

/* Check the audit log */
SELECT * FROM Audit.Package_Control;
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

/* Load fact tables from the source database */

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
FROM WideWorldImporters.Sales.Orders;
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
	OrderLineID,
    OrderID,
    Quantity,
    UnitPrice
FROM WideWorldImporters.Sales.OrderLines;
GO

/* Execute SSIS packages: 01-LoadDimCity.dtsx, 02-LoadDimCustomer.dtsx, 11-LoadFactSalesOrders.dtsx */

/* Check the content of the dimension and fact tables */
SELECT * FROM Dim.City;
SELECT * FROM Dim.Customer;
SELECT * FROM Fact.SalesOrders;
GO

/* Check the audit log */
SELECT * FROM Audit.Package_Control;
GO
