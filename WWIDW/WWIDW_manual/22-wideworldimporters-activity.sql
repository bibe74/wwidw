/*
SET NOEXEC OFF;
--*/ SET NOEXEC ON;

/*
 * file: 22-wideworldimporters-activity.sql
*/

USE WideWorldImporters;
GO

/* Cleanup

DELETE OL
FROM Sales.OrderLines OL
INNER JOIN Sales.Orders O ON O.OrderID = OL.OrderID
INNER JOIN Sales.Customers C ON C.CustomerID = O.CustomerID
WHERE C.CustomerName = N'SQL Saturday Pordenone';

DELETE O
FROM Sales.Orders O
INNER JOIN Sales.Customers C ON C.CustomerID = O.CustomerID
WHERE C.CustomerName = N'SQL Saturday Pordenone';

DELETE FROM Sales.Customers WHERE CustomerName = N'SQL Saturday Pordenone';

DELETE FROM Application.Cities WHERE CityName = N'Pordenone';

DELETE FROM Application.StateProvinces WHERE StateProvinceName = N'Friuli Venezia-Giulia';
GO

*/

/* Insert a new Customer */

/* Retrieve Italy's CountryID */
SELECT * FROM Application.Countries WHERE CountryName = N'Italy'; -- CountryID = 106
GO

/* Retrieve Friuli Venezia-Giulia's StateProvinceID */
SELECT * FROM Application.StateProvinces WHERE CountryID = 106;
GO

INSERT INTO Application.StateProvinces
(
    --StateProvinceID,
    StateProvinceCode,
    StateProvinceName,
    CountryID,
    SalesTerritory,
    Border,
    LatestRecordedPopulation,
    LastEditedBy
)
VALUES
(   --0,             -- StateProvinceID - int
    N'FVG',           -- StateProvinceCode - nvarchar(5)
    N'Friuli Venezia-Giulia',           -- StateProvinceName - nvarchar(50)
    106,             -- CountryID - int
    N'Nord-Est',           -- SalesTerritory - nvarchar(50)
    NULL,          -- Border - geography
    0,             -- LatestRecordedPopulation - bigint
    1             -- LastEditedBy - int
);
GO

SELECT * FROM Application.StateProvinces WHERE CountryID = 106; -- StateProvinceID = 55
GO

/* Retrieve Pordenone's CityID */
SELECT * FROM Application.Cities WHERE StateProvinceID = 55;
GO

INSERT INTO Application.Cities
(
    --CityID,
    CityName,
    StateProvinceID,
    Location,
    LatestRecordedPopulation,
    LastEditedBy
)
VALUES
(   --0,             -- CityID - int
    N'Pordenone',           -- CityName - nvarchar(50)
    55,             -- StateProvinceID - int
    NULL,          -- Location - geography
    0,             -- LatestRecordedPopulation - bigint
    1             -- LastEditedBy - int
);
GO

SELECT * FROM Application.Cities WHERE StateProvinceID = 55; -- CityID = 38187
GO

/* Retrieve SQL Saturday Pordenone's CustomerID */
SELECT * FROM Sales.Customers WHERE CustomerName = N'SQL Saturday Pordenone';
GO

INSERT INTO Sales.Customers
(
    --CustomerID,
    CustomerName,
    BillToCustomerID,
    CustomerCategoryID,
    BuyingGroupID,
    PrimaryContactPersonID,
    AlternateContactPersonID,
    DeliveryMethodID,
    DeliveryCityID,
    PostalCityID,
    CreditLimit,
    AccountOpenedDate,
    StandardDiscountPercentage,
    IsStatementSent,
    IsOnCreditHold,
    PaymentDays,
    PhoneNumber,
    FaxNumber,
    DeliveryRun,
    RunPosition,
    WebsiteURL,
    DeliveryAddressLine1,
    DeliveryAddressLine2,
    DeliveryPostalCode,
    DeliveryLocation,
    PostalAddressLine1,
    PostalAddressLine2,
    PostalPostalCode,
    LastEditedBy
)
SELECT TOP 1
	--CustomerID,
    N'SQL Saturday Pordenone' AS CustomerName,
    BillToCustomerID,
    CustomerCategoryID,
    BuyingGroupID,
    PrimaryContactPersonID,
    AlternateContactPersonID,
    DeliveryMethodID,
    38188 AS DeliveryCityID,
    PostalCityID,
    CreditLimit,
    AccountOpenedDate,
    StandardDiscountPercentage,
    IsStatementSent,
    IsOnCreditHold,
    PaymentDays,
    PhoneNumber,
    FaxNumber,
    DeliveryRun,
    RunPosition,
    WebsiteURL,
    DeliveryAddressLine1,
    DeliveryAddressLine2,
    DeliveryPostalCode,
    DeliveryLocation,
    PostalAddressLine1,
    PostalAddressLine2,
    PostalPostalCode,
    LastEditedBy
FROM Sales.Customers;
GO

SELECT * FROM Sales.Customers WHERE CustomerName = N'SQL Saturday Pordenone'; -- CustomerID = 1062
GO

/* Modify a customer: Wingtip Toys (Homer City, PA) moves from Homer City, PA to Springfield, PA */
UPDATE Sales.Customers
SET DeliveryCityID = 32498
WHERE CustomerID = 442;
GO

/* Insert a new order */
INSERT INTO Sales.Orders
(
    --OrderID,
    CustomerID,
    SalespersonPersonID,
    PickedByPersonID,
    ContactPersonID,
    BackorderOrderID,
    OrderDate,
    ExpectedDeliveryDate,
    CustomerPurchaseOrderNumber,
    IsUndersupplyBackordered,
    Comments,
    DeliveryInstructions,
    InternalComments,
    PickingCompletedWhen,
    LastEditedBy,
    LastEditedWhen
)
SELECT TOP 1
	--OrderID,
    1062 AS CustomerID,
    SalespersonPersonID,
    PickedByPersonID,
    ContactPersonID,
    BackorderOrderID,
    CURRENT_TIMESTAMP AS OrderDate,
    DATEADD(dd, 3, CURRENT_TIMESTAMP) AS ExpectedDeliveryDate,
    CustomerPurchaseOrderNumber,
    IsUndersupplyBackordered,
    Comments,
    DeliveryInstructions,
    InternalComments,
    PickingCompletedWhen,
    LastEditedBy,
    CURRENT_TIMESTAMP AS LastEditedWhen
FROM Sales.Orders;
GO

SELECT * FROM Sales.Orders WHERE CustomerID = 1062 ORDER BY OrderID DESC; -- OrderID = 73596
GO

INSERT INTO Sales.OrderLines
(
    --OrderLineID,
    OrderID,
    StockItemID,
    Description,
    PackageTypeID,
    Quantity,
    UnitPrice,
    TaxRate,
    PickedQuantity,
    PickingCompletedWhen,
    LastEditedBy,
    LastEditedWhen
)
SELECT TOP 1
	--OrderLineID,
    73596 AS OrderID,
    StockItemID,
    Description,
    PackageTypeID,
    Quantity,
    UnitPrice,
    TaxRate,
    PickedQuantity,
    PickingCompletedWhen,
    LastEditedBy,
    LastEditedWhen
FROM Sales.OrderLines;
GO
