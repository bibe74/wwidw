/*
SET NOEXEC OFF;
--*/ SET NOEXEC ON;

/*
 * file: 01-wideworldimporters-discovery.sql
*/

USE WideWorldImporters;
GO

/* Inspect orders, customers and geography */

SELECT TOP 1 * FROM Sales.OrderLines;
SELECT TOP 1 * FROM Sales.Orders;
SELECT TOP 1 * FROM Sales.Customers;
SELECT TOP 1 * FROM Sales.CustomerCategories;
SELECT TOP 1 * FROM Application.Cities;
SELECT TOP 1 * FROM Application.StateProvinces;
SELECT TOP 1 * FROM Application.Countries;
GO

SELECT TOP 1
	SOL.OrderLineID,
	SOL.OrderID,
	SO.OrderID,
	SO.CustomerID,
	SC.CustomerID,
	SC.CustomerName,
	SC.DeliveryCityID,
	ACi.CityID,
	ACi.CityName AS DeliveryCityName,
	ACi.StateProvinceID AS DeliveryStateProvinceID,
	ASP.StateProvinceID,
	ASP.StateProvinceCode AS DeliveryStateProvinceCode,
	ASP.StateProvinceName AS DeliveryStateProvinceName,
	ASP.CountryID AS DeliveryCountryID,
	ACo.CountryID,
	ACo.CountryName AS DeliveryCountryName,
	ACo.Region AS DeliveryRegion,
	ACo.Subregion AS DeliverySubRegion,
	SO.OrderDate,

	SOL.Quantity,
	SOL.Quantity * SOL.UnitPrice AS Amount

FROM Sales.OrderLines SOL
INNER JOIN Sales.Orders SO ON SO.OrderID = SOL.OrderID
INNER JOIN Sales.Customers SC ON SC.CustomerID = SO.CustomerID
INNER JOIN Application.Cities ACi ON ACi.CityID = SC.DeliveryCityID
INNER JOIN Application.StateProvinces ASP ON ASP.StateProvinceID = ACi.StateProvinceID
INNER JOIN Application.Countries ACo ON ACo.CountryID = ASP.CountryID;
GO

SELECT TOP 1
	OrderLineID,
	OrderID,
	Quantity,
	UnitPrice

FROM Sales.OrderLines;
GO

SELECT TOP 1
	OrderID,
	OrderDate,
	CustomerID

FROM Sales.Orders;
GO

SELECT TOP 1
	CustomerID,
	CustomerName,
	DeliveryCityID

FROM Sales.Customers;
GO

SELECT TOP 1
	CityID,
	CityName,
	StateProvinceID

FROM Application.Cities;
GO

SELECT TOP 1
	StateProvinceID,
	StateProvinceCode,
	StateProvinceName,
	CountryID

FROM Application.StateProvinces;
GO

SELECT TOP 1
	CountryID,
	CountryName,
    Region,
    Subregion

FROM Application.Countries;
GO
