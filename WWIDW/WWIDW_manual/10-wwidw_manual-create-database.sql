/*
SET NOEXEC OFF;
--*/ SET NOEXEC ON;

/*
 * file: 10-wwidw_manual-create-database.sql
*/

USE master;
GO

DROP DATABASE IF EXISTS WWIDW_manual;
GO

CREATE DATABASE WWIDW_manual
CONTAINMENT = NONE
ON  PRIMARY 
( NAME = N'WWIDW_manual', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQL2017\MSSQL\DATA\WWIDW_manual.mdf' , SIZE = 65536KB , FILEGROWTH = 65536KB )
LOG ON ( NAME = N'WWIDW_manual_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.SQL2017\MSSQL\DATA\WWIDW_manual_log.ldf' , SIZE = 8192KB , FILEGROWTH = 65536KB );
GO

USE WWIDW_manual;
GO
