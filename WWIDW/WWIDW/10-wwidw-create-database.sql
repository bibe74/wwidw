/*
SET NOEXEC OFF;
--*/ SET NOEXEC ON;

/*
 * file: 10-wwidw-create-database.sql
*/

USE master;
GO

DROP DATABASE IF EXISTS WWIDW;
GO

CREATE DATABASE WWIDW
CONTAINMENT = NONE
ON  PRIMARY 
( NAME = N'WWIDW', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQL2017\MSSQL\DATA\WWIDW.mdf' , SIZE = 65536KB , FILEGROWTH = 65536KB )
LOG ON ( NAME = N'WWIDW_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQL2017\MSSQL\DATA\WWIDW_log.ldf' , SIZE = 8192KB , FILEGROWTH = 65536KB )
COLLATE Latin1_General_100_CI_AS; -- Use the same collation as WideWorldImporters database
GO

USE WWIDW;
GO
