/*
SET NOEXEC OFF;
--*/ SET NOEXEC ON;

/*
 * file: 00-wideworldimporters-setup.sql
*/

/* Download the WideWorldImporters sample database from Microsoft's GitHub page: https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
This file contains sample TSQL to restore the file WideWorldImporters-Full.bak
Notes & Warnings:
    This will BLOW AWAY any existing database named WideWorldImporters.
    Adjust the location of the backup file to the location you stored it on your test instance.
    This is suitable for dedicated test instances only.
*/

USE master;
GO

/* If the database doesn't exist, create it */
IF DB_ID('WideWorldImporters') IS NULL
BEGIN
    CREATE DATABASE WideWorldImporters;
END
GO

/* If the database exists (it should!), kick everyone out */
IF DB_ID('WideWorldImporters') IS NOT NULL
BEGIN
    ALTER DATABASE WideWorldImporters SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
END
GO

/* Restore - and replace if it exists */
RESTORE DATABASE WideWorldImporters
    --FROM DISK='S:\MSSQL\Backup\WideWorldImporters-Full.bak'
    FROM DISK='C:\Program Files\Microsoft SQL Server\MSSQL14.SQL2017\MSSQL\Backup\WideWorldImporters-Full.bak'
    WITH REPLACE,
    STATS=10;
GO
