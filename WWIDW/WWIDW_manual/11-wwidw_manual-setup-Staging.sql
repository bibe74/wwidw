/*
SET NOEXEC OFF;
--*/ SET NOEXEC ON;

/*
 * file: 11-wwidw_manual-setup-Staging.sql
*/

USE WWIDW_manual;
GO

/*
	Staging schema
	We'll load a "copy" of the OLTP tables, limited to the columns needed for the data warehouse loading process.
	If CDC is enabled on the OLTP fact tables, we'll load only the inserted/updated records.
*/

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = N'Staging')
BEGIN
	EXEC ('CREATE SCHEMA Staging AUTHORIZATION dbo;');
END;
GO

CREATE TABLE Staging.Application_Countries(
	[CountryID] [int] NOT NULL,
	[CountryName] [nvarchar](60) NOT NULL,
	[Region] [nvarchar](30) NOT NULL,
	[Subregion] [nvarchar](30) NOT NULL,
 CONSTRAINT [PK_Application_Countries] PRIMARY KEY CLUSTERED 
(
	[CountryID] ASC
));
GO

CREATE TABLE Staging.Application_StateProvinces(
	[StateProvinceID] [int] NOT NULL,
	[StateProvinceCode] [nvarchar](5) NOT NULL,
	[StateProvinceName] [nvarchar](50) NOT NULL,
	[CountryID] [int] NOT NULL,
 CONSTRAINT [PK_Application_StateProvinces] PRIMARY KEY CLUSTERED 
(
	[StateProvinceID] ASC
));
GO

ALTER TABLE Staging.Application_StateProvinces ADD CONSTRAINT FK_Application_StateProvinces_CountryID FOREIGN KEY (CountryID) REFERENCES Staging.Application_Countries (CountryID);
GO

CREATE TABLE Staging.Application_Cities(
	[CityID] [int] NOT NULL,
	[CityName] [nvarchar](50) NOT NULL,
	[StateProvinceID] [int] NOT NULL,
 CONSTRAINT [PK_Application_Cities] PRIMARY KEY CLUSTERED 
(
	[CityID] ASC
));
GO

ALTER TABLE Staging.Application_Cities ADD CONSTRAINT FK_Application_Cities_StateProvinceID FOREIGN KEY (StateProvinceID) REFERENCES Staging.Application_StateProvinces (StateProvinceID);
GO

CREATE TABLE Staging.Sales_Customers(
	[CustomerID] [int] NOT NULL,
	[CustomerName] [nvarchar](100) NOT NULL,
	[DeliveryCityID] [int] NOT NULL,
 CONSTRAINT [PK_Sales_Customers] PRIMARY KEY CLUSTERED 
(
	[CustomerID] ASC
));
GO

ALTER TABLE Staging.Sales_Customers ADD CONSTRAINT FK_Staging_Sales_Customers_DeliveryCityID FOREIGN KEY (DeliveryCityID) REFERENCES Staging.Application_Cities (CityID);
GO

CREATE TABLE Staging.Sales_Orders(
	[OrderID] [int] NOT NULL,
	[CustomerID] [int] NOT NULL,
	[OrderDate] [date] NOT NULL,
 CONSTRAINT [PK_Sales_Orders] PRIMARY KEY CLUSTERED 
(
	[OrderID] ASC
));
GO

ALTER TABLE Staging.Sales_Orders ADD CONSTRAINT FK_Staging_SalesOrders_CustomerID FOREIGN KEY (CustomerID) REFERENCES Staging.Sales_Customers (CustomerID);
GO

CREATE TABLE Staging.Sales_OrderLines(
	[OrderLineID] [int] NOT NULL,
	[OrderID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [decimal](18, 2) NULL,
 CONSTRAINT [PK_Sales_OrderLines] PRIMARY KEY CLUSTERED 
(
	[OrderLineID] ASC
));
GO

ALTER TABLE Staging.Sales_OrderLines ADD CONSTRAINT FK_Staging_OrderLines_OrderID FOREIGN KEY (OrderID) REFERENCES Staging.Sales_Orders (OrderID);
GO

/* Install database diagram support, create a new diagram with all the Staging tables */

/* Drop all staging foreign key constraints */
ALTER TABLE Staging.Sales_OrderLines DROP CONSTRAINT FK_Staging_OrderLines_OrderID;
ALTER TABLE Staging.Sales_Orders DROP CONSTRAINT FK_Staging_SalesOrders_CustomerID;
ALTER TABLE Staging.Sales_Customers DROP CONSTRAINT FK_Staging_Sales_Customers_DeliveryCityID;
ALTER TABLE Staging.Application_Cities DROP CONSTRAINT FK_Application_Cities_StateProvinceID;
ALTER TABLE Staging.Application_StateProvinces DROP CONSTRAINT FK_Application_StateProvinces_CountryID;
GO
