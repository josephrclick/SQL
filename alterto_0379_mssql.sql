USE CAFUSER;
GO
CREATE TABLE SchemaAlteration_Log (AlterLogID INT NOT NULL IDENTITY(1,1) PRIMARY KEY NONCLUSTERED ,
AlterResult VARCHAR(10) NOT NULL DEFAULT '',
AlterErrorMessage    VARCHAR(200) NOT NULL DEFAULT '')
GO
INSERT INTO SchemaAlteration_Log(AlterResult,AlterErrorMessage) values ('','')
GO
DECLARE @scriptversion CHAR(10),@currentversion CHAR(10)
SET @scriptversion = '379' -- NEW VERSION
SELECT @currentversion = LTRIM(RTRIM(VARIABLEVALUE))
FROM cafuser.dbo.configuration_variables
WHERE UPPER(LTRIM(RTRIM(VARIABLENAME)))='SCHEMAVERSION'
IF (CAST(LTRIM(RTRIM(@scriptversion)) AS INT) <= CAST(LTRIM(RTRIM(@currentversion)) AS INT)) BEGIN
UPDATE SchemaAlteration_Log
SET AlterResult = 'BAD'
,AlterErrorMessage = 'The current version of the Schema is Newer than the Alter version ' + @scriptversion
END
GO
IF EXISTS(SELECT * FROM SchemaAlteration_Log WHERE UPPER(LTRIM(RTRIM(AlterResult)))='BAD') BEGIN
GOTO END_PROCEDURE
END


BEGIN
DECLARE @seqid decimal
exec nextseqnobytablename 'update_history',@seqid out
insert into update_history (updatehistoryid, updatedate, version, completed, deleted)
(select @seqid, getdate(), '379', '0', '0');

END
END_PROCEDURE:
GO
IF EXISTS(SELECT * FROM SchemaAlteration_Log WHERE UPPER(LTRIM(RTRIM(AlterResult)))='BAD') BEGIN
GOTO END_PROCEDURE
END
END_PROCEDURE:
GO
IF EXISTS(SELECT * FROM SchemaAlteration_Log WHERE UPPER(LTRIM(RTRIM(AlterResult)))='BAD') BEGIN
GOTO END_PROCEDURE
END

-- ******************Original ALTER starts here ********************
-- BEGIN VERSION 379
-- MSSQL
--

--caf-47053
delete from configuration_variables where variablename='trfdsp_arcusr'
 and configurationvariableid not in (
    select min(configurationvariableid) id from configuration_variables where variablename='trfdsp_arcusr'
 );

END_PROCEDURE:
GO
IF EXISTS(SELECT * FROM SchemaAlteration_Log WHERE UPPER(LTRIM(RTRIM(AlterResult)))='BAD') BEGIN
GOTO END_PROCEDURE
END

 
-- END VERSION 379, RELEASED:
-- ******************Original ALTER ends here ************************


update update_history
   set completed = '1'
 where version = '379';
END_PROCEDURE:
GO
IF EXISTS(SELECT * FROM SchemaAlteration_Log WHERE UPPER(LTRIM(RTRIM(AlterResult)))='BAD') BEGIN
GOTO END_PROCEDURE
END


update configuration_variables set variablevalue = '379' where variablename = 'schemaversion';
END_PROCEDURE:
GO
IF EXISTS(SELECT * FROM SchemaAlteration_Log WHERE UPPER(LTRIM(RTRIM(AlterResult)))='BAD') BEGIN
GOTO END_PROCEDURE
END
--EXIT PROCEDURE;
--no_slashes
END_PROCEDURE:
GO
select AlterErrorMessage from SchemaAlteration_Log
GO
DROP TABLE SchemaAlteration_Log
GO
