/*
SET NOEXEC OFF;
--*/ SET NOEXEC ON;

/*
 * file: 15-wwidw_manual-setup-Audit.sql
*/

USE WWIDW_manual;
GO

/* Audit schema - Logs */

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = N'Audit')
BEGIN
	EXEC ('CREATE SCHEMA Audit AUTHORIZATION dbo;');
END;
GO

CREATE TABLE [Audit].[Package_Control](
	[Package_NM] [varchar](100) NOT NULL,
	[Package_ID] [uniqueidentifier] NOT NULL,
	[Parent_Package_ID] [uniqueidentifier] NULL,
	[Execution_ID] [bigint] NULL,
	[Start_TS] [datetime] NOT NULL,
	[Stop_TS] [datetime] NULL,
	[Insert_Row_QT] [int] NULL,
	[Update_Row_QT] [int] NULL,
	[Unchanged_Row_QT] [int] NULL,
	[Deleted_Row_QT] [int] NULL,
	[Duration_s]  AS (datediff(second,[Start_TS],[Stop_TS])),
	[PackageLogID] [int] IDENTITY(1,1) NOT NULL
)
GO

CREATE PROCEDURE [Audit].[PackageControlStart]
(
    @PackageName varchar(100)
,   @PackageId uniqueidentifier
,   @ParentPackageId uniqueidentifier = NULL
,   @ExecutionId bigint
,   @StartTime DATETIME
,   @StopTime datetime = NULL
,   @InsertRowQuantity int = NULL
,   @UpdateRowQuantity int = NULL
,   @UnchangedRowQuantity int = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
	DECLARE @PackageLogId int 
    INSERT INTO [Audit].[Package_Control]
    (
        [Package_NM]
    ,   [Package_ID]
    ,   [Parent_Package_ID]
    ,   [Execution_ID]
    ,   [Start_TS]
    ,   [Stop_TS]
    ,   [Insert_Row_QT]
    ,   [Update_Row_QT]
    ,	[Unchanged_Row_QT]
    )
    SELECT
        @PackageName 
    ,   @PackageId 
    ,   @ParentPackageId 
    ,   @ExecutionId 
    ,   CURRENT_TIMESTAMP
    ,   @StopTime 
    ,   @InsertRowQuantity 
    ,   @UpdateRowQuantity 
    ,	@UnchangedRowQuantity
  SELECT @PackageLogID = SCOPE_IDENTITY()
  SELECT  @PackageLogID as PackageLogID
END
GO

CREATE PROCEDURE [Audit].[PackageControlStop]
(
    @PackageId uniqueidentifier
,   @ExecutionId bigint
,   @InsertRowQuantity int = NULL
,   @UpdateRowQuantity int = NULL
,	@UnchangedRowQuantity int = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    -- Close out the execution.
    UPDATE PC
    SET [Stop_TS] = CURRENT_TIMESTAMP  
    ,   [Insert_Row_QT] = @InsertRowQuantity
    ,   [Update_Row_QT] = @UpdateRowQuantity
	,	[Unchanged_Row_QT] = @UnchangedRowQuantity
    FROM  [Audit].[Package_Control] AS PC
    WHERE PC.Package_ID = @PackageId
        AND PC.Execution_ID = @ExecutionId
        AND PC.[Stop_TS] IS NULL;  
END
GO
