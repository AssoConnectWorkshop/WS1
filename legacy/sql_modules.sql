-- ===== SQL_STORED_PROCEDURE dbo.dt_addtosourcecontrol
create proc dbo.dt_addtosourcecontrol
    @vchSourceSafeINI varchar(255) = '',
    @vchProjectName   varchar(255) ='',
    @vchComment       varchar(255) ='',
    @vchLoginName     varchar(255) ='',
    @vchPassword      varchar(255) =''

as

set nocount on

declare @iReturn int
declare @iObjectId int
select @iObjectId = 0

declare @iStreamObjectId int
select @iStreamObjectId = 0

declare @VSSGUID varchar(100)
select @VSSGUID = 'SQLVersionControl.VCS_SQL'

declare @vchDatabaseName varchar(255)
select @vchDatabaseName = db_name()

declare @iReturnValue int
select @iReturnValue = 0

declare @iPropertyObjectId int
declare @vchParentId varchar(255)

declare @iObjectCount int
select @iObjectCount = 0

    exec @iReturn = sp_OACreate @VSSGUID, @iObjectId OUT
    if @iReturn <> 0 GOTO E_OAError


    /* Create Project in SS */
    exec @iReturn = sp_OAMethod @iObjectId,
                                'AddProjectToSourceSafe',
                                NULL,
                                @vchSourceSafeINI,
                                @vchProjectName output,
                                @@SERVERNAME,
                                @vchDatabaseName,
                                @vchLoginName,
                                @vchPassword,
                                @vchComment


    if @iReturn <> 0 GOTO E_OAError

    exec @iReturn = sp_OAGetProperty @iObjectId, 'GetStreamObject', @iStreamObjectId OUT

    if @iReturn <> 0 GOTO E_OAError

    /* Set Database Properties */

    begin tran SetProperties

    /* add high level object */

    exec @iPropertyObjectId = dbo.dt_adduserobject_vcs 'VCSProjectID'

    select @vchParentId = CONVERT(varchar(255),@iPropertyObjectId)

    exec dbo.dt_setpropertybyid @iPropertyObjectId, 'VCSProjectID', @vchParentId , NULL
    exec dbo.dt_setpropertybyid @iPropertyObjectId, 'VCSProject' , @vchProjectName , NULL
    exec dbo.dt_setpropertybyid @iPropertyObjectId, 'VCSSourceSafeINI' , @vchSourceSafeINI , NULL
    exec dbo.dt_setpropertybyid @iPropertyObjectId, 'VCSSQLServer', @@SERVERNAME, NULL
    exec dbo.dt_setpropertybyid @iPropertyObjectId, 'VCSSQLDatabase', @vchDatabaseName, NULL

    if @@error <> 0 GOTO E_General_Error

    commit tran SetProperties

    declare cursorProcNames cursor for
        select convert(varchar(255), name) from sysobjects where type = 'P' and name not like 'dt_%'
    open cursorProcNames

    while 1 = 1
    begin
        declare @vchProcName varchar(255)
        fetch next from cursorProcNames into @vchProcName
        if @@fetch_status <> 0
            break

        select colid, text into #ProcLines
        from syscomments
        where id = object_id(@vchProcName)
        order by colid

        declare @iCurProcLine int
        declare @iProcLines int
        select @iCurProcLine = 1
        select @iProcLines = (select count(*) from #ProcLines)
        while @iCurProcLine <= @iProcLines
        begin
            declare @pos int
            select @pos = 1
            declare @iCurLineSize int
            select @iCurLineSize = len((select text from #ProcLines where colid = @iCurProcLine))
            while @pos <= @iCurLineSize
            begin
                declare @vchProcLinePiece varchar(255)
                select @vchProcLinePiece = convert(varchar(255),
                    substring((select text from #ProcLines where colid = @iCurProcLine),
                              @pos, 255 ))
                exec @iReturn = sp_OAMethod @iStreamObjectId, 'AddStream', @iReturnValue OUT, @vchProcLinePiece
                if @iReturn <> 0 GOTO E_OAError
                select @pos = @pos + 255
            end
            select @iCurProcLine = @iCurProcLine + 1
        end
        drop table #ProcLines

        exec @iReturn = sp_OAMethod @iObjectId,
                                    'CheckIn_StoredProcedure',
                                    NULL,
                                    @sProjectName = @vchProjectName,
                                    @sSourceSafeINI = @vchSourceSafeINI,
                                    @sServerName = @@SERVERNAME,
                                    @sDatabaseName = @vchDatabaseName,
                                    @sObjectName = @vchProcName,
                                    @sComment = @vchComment,
                                    @sLoginName = @vchLoginName,
                                    @sPassword = @vchPassword,
                                    @iVCSFlags = 0,
                                    @iActionFlag = 0,
                                    @sStream = ''

        if @iReturn = 0 select @iObjectCount = @iObjectCount + 1

    end

CleanUp:
	close cursorProcNames
	deallocate cursorProcNames
    select @vchProjectName
    select @iObjectCount
    return

E_General_Error:
    /* this is an all or nothing.  No specific error messages */
    goto CleanUp

E_OAError:
    exec dbo.dt_displayoaerror @iObjectId, @iReturn
    goto CleanUp



GO
-- ===== SQL_STORED_PROCEDURE dbo.dt_addtosourcecontrol_u
create proc dbo.dt_addtosourcecontrol_u
    @vchSourceSafeINI nvarchar(255) = '',
    @vchProjectName   nvarchar(255) ='',
    @vchComment       nvarchar(255) ='',
    @vchLoginName     nvarchar(255) ='',
    @vchPassword      nvarchar(255) =''

as

set nocount on

declare @iReturn int
declare @iObjectId int
select @iObjectId = 0

declare @iStreamObjectId int
select @iStreamObjectId = 0

declare @VSSGUID nvarchar(100)
select @VSSGUID = N'SQLVersionControl.VCS_SQL'

declare @vchDatabaseName varchar(255)
select @vchDatabaseName = db_name()

declare @iReturnValue int
select @iReturnValue = 0

declare @iPropertyObjectId int
declare @vchParentId nvarchar(255)

declare @iObjectCount int
select @iObjectCount = 0

    exec @iReturn = sp_OACreate @VSSGUID, @iObjectId OUT
    if @iReturn <> 0 GOTO E_OAError


    /* Create Project in SS */
    exec @iReturn = sp_OAMethod @iObjectId,
                                'AddProjectToSourceSafe',
                                NULL,
                                @vchSourceSafeINI,
                                @vchProjectName output,
                                @@SERVERNAME,
                                @vchDatabaseName,
                                @vchLoginName,
                                @vchPassword,
                                @vchComment


    if @iReturn <> 0 GOTO E_OAError

    exec @iReturn = sp_OAGetProperty @iObjectId, N'GetStreamObject', @iStreamObjectId OUT

    if @iReturn <> 0 GOTO E_OAError

    /* Set Database Properties */

    begin tran SetProperties

    /* add high level object */

    exec @iPropertyObjectId = dbo.dt_adduserobject_vcs 'VCSProjectID'

    select @vchParentId = CONVERT(nvarchar(255),@iPropertyObjectId)

    exec dbo.dt_setpropertybyid_u @iPropertyObjectId, 'VCSProjectID', @vchParentId , NULL
    exec dbo.dt_setpropertybyid_u @iPropertyObjectId, 'VCSProject' , @vchProjectName , NULL
    exec dbo.dt_setpropertybyid_u @iPropertyObjectId, 'VCSSourceSafeINI' , @vchSourceSafeINI , NULL
    exec dbo.dt_setpropertybyid_u @iPropertyObjectId, 'VCSSQLServer', @@SERVERNAME, NULL
    exec dbo.dt_setpropertybyid_u @iPropertyObjectId, 'VCSSQLDatabase', @vchDatabaseName, NULL

    if @@error <> 0 GOTO E_General_Error

    commit tran SetProperties

    declare cursorProcNames cursor for
        select convert(nvarchar(255), name) from sysobjects where type = N'P' and name not like N'dt_%'
    open cursorProcNames

    while 1 = 1
    begin
        declare @vchProcName nvarchar(255)
        fetch next from cursorProcNames into @vchProcName
        if @@fetch_status <> 0
            break

        select colid, text into #ProcLines
        from syscomments
        where id = object_id(@vchProcName)
        order by colid

        declare @iCurProcLine int
        declare @iProcLines int
        select @iCurProcLine = 1
        select @iProcLines = (select count(*) from #ProcLines)
        while @iCurProcLine <= @iProcLines
        begin
            declare @pos int
            select @pos = 1
            declare @iCurLineSize int
            select @iCurLineSize = len((select text from #ProcLines where colid = @iCurProcLine))
            while @pos <= @iCurLineSize
            begin
                declare @vchProcLinePiece nvarchar(255)
                select @vchProcLinePiece = convert(nvarchar(255),
                    substring((select text from #ProcLines where colid = @iCurProcLine),
                              @pos, 255 ))
                exec @iReturn = sp_OAMethod @iStreamObjectId, N'AddStream', @iReturnValue OUT, @vchProcLinePiece
                if @iReturn <> 0 GOTO E_OAError
                select @pos = @pos + 255
            end
            select @iCurProcLine = @iCurProcLine + 1
        end
        drop table #ProcLines

        exec @iReturn = sp_OAMethod @iObjectId,
                                    'CheckIn_StoredProcedure',
                                    NULL,
                                    @sProjectName = @vchProjectName,
                                    @sSourceSafeINI = @vchSourceSafeINI,
                                    @sServerName = @@SERVERNAME,
                                    @sDatabaseName = @vchDatabaseName,
                                    @sObjectName = @vchProcName,
                                    @sComment = @vchComment,
                                    @sLoginName = @vchLoginName,
                                    @sPassword = @vchPassword,
                                    @iVCSFlags = 0,
                                    @iActionFlag = 0,
                                    @sStream = ''

        if @iReturn = 0 select @iObjectCount = @iObjectCount + 1

    end

CleanUp:
	close cursorProcNames
	deallocate cursorProcNames
    select @vchProjectName
    select @iObjectCount
    return

E_General_Error:
    /* this is an all or nothing.  No specific error messages */
    goto CleanUp

E_OAError:
    exec dbo.dt_displayoaerror_u @iObjectId, @iReturn
    goto CleanUp



GO
-- ===== SQL_STORED_PROCEDURE dbo.dt_adduserobject
/*
**	Add an object to the dtproperties table
*/
create procedure dbo.dt_adduserobject
as
	set nocount on
	/*
	** Create the user object if it does not exist already
	*/
	begin transaction
		insert dbo.dtproperties (property) VALUES ('DtgSchemaOBJECT')
		update dbo.dtproperties set objectid=@@identity 
			where id=@@identity and property='DtgSchemaOBJECT'
	commit
	return @@identity

GO
-- ===== SQL_STORED_PROCEDURE dbo.dt_adduserobject_vcs
create procedure dbo.dt_adduserobject_vcs
    @vchProperty varchar(64)

as

set nocount on

declare @iReturn int
    /*
    ** Create the user object if it does not exist already
    */
    begin transaction
        select @iReturn = objectid from dbo.dtproperties where property = @vchProperty
        if @iReturn IS NULL
        begin
            insert dbo.dtproperties (property) VALUES (@vchProperty)
            update dbo.dtproperties set objectid=@@identity
                    where id=@@identity and property=@vchProperty
            select @iReturn = @@identity
        end
    commit
    return @iReturn



GO
-- ===== SQL_STORED_PROCEDURE dbo.dt_checkinobject
create proc dbo.dt_checkinobject
    @chObjectType  char(4),
    @vchObjectName varchar(255),
    @vchComment    varchar(255)='',
    @vchLoginName  varchar(255),
    @vchPassword   varchar(255)='',
    @iVCSFlags     int = 0,
    @iActionFlag   int = 0,   /* 0 => AddFile, 1 => CheckIn */
    @txStream1     Text = '', /* There is a bug that if items are NULL they do not pass to OLE servers */
    @txStream2     Text = '',
    @txStream3     Text = ''


as

set nocount on

declare @iReturn int
declare @iObjectId int
select @iObjectId = 0

declare @VSSGUID varchar(100)
select @VSSGUID = 'SQLVersionControl.VCS_SQL'


declare @iPropertyObjectId int
select @iPropertyObjectId  = 0

    select @iPropertyObjectId = (select objectid from dbo.dtproperties where property = 'VCSProjectID')

    declare @vchProjectName   varchar(255)
    declare @vchSourceSafeINI varchar(255)
    declare @vchServerName    varchar(255)
    declare @vchDatabaseName  varchar(255)
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSProject',       @vchProjectName   OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSourceSafeINI', @vchSourceSafeINI OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSQLServer',     @vchServerName    OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSQLDatabase',   @vchDatabaseName  OUT

    if @chObjectType = 'PROC'
    begin
        if @iActionFlag = 1
        begin
            /* Procedure Can have up to three streams
            Drop Stream, Create Stream, GRANT stream */

            begin tran compile_all

            /* try to compile the streams */
            exec (@txStream1)
            if @@error <> 0 GOTO E_Compile_Fail

            exec (@txStream2)
            if @@error <> 0 GOTO E_Compile_Fail

            exec (@txStream3)
            if @@error <> 0 GOTO E_Compile_Fail
        end

        exec @iReturn = sp_OACreate @VSSGUID, @iObjectId OUT
        if @iReturn <> 0 GOTO E_OAError

        if @iActionFlag = 1
        begin
            exec @iReturn = sp_OAMethod @iObjectId,
                                        'CheckIn_StoredProcedure',
                                        NULL,
                                        @sProjectName = @vchProjectName,
                                        @sSourceSafeINI = @vchSourceSafeINI,
                                        @sServerName = @vchServerName,
                                        @sDatabaseName = @vchDatabaseName,
                                        @sObjectName = @vchObjectName,
                                        @sComment = @vchComment,
                                        @sLoginName = @vchLoginName,
                                        @sPassword = @vchPassword,
                                        @iVCSFlags = @iVCSFlags,
                                        @iActionFlag = @iActionFlag,
                                        @sStream = @txStream2
        end
        else
        begin
            declare @iStreamObjectId int
            declare @iReturnValue int

            exec @iReturn = sp_OAGetProperty @iObjectId, 'GetStreamObject', @iStreamObjectId OUT
            if @iReturn <> 0 GOTO E_OAError

            select colid, text into #ProcLines
            from syscomments
            where id = object_id(@vchObjectName)
            order by colid

            declare @iCurProcLine int
            declare @iProcLines int
            select @iCurProcLine = 1
            select @iProcLines = (select count(*) from #ProcLines)
            while @iCurProcLine <= @iProcLines
            begin
                declare @pos int
                select @pos = 1
                declare @iCurLineSize int
                select @iCurLineSize = len((select text from #ProcLines where colid = @iCurProcLine))
                while @pos <= @iCurLineSize
                begin
                    declare @vchProcLinePiece varchar(255)
                    select @vchProcLinePiece = convert(varchar(255),
                        substring((select text from #ProcLines where colid = @iCurProcLine),
                                  @pos, 255 ))
                    exec @iReturn = sp_OAMethod @iStreamObjectId, 'AddStream', @iReturnValue OUT, @vchProcLinePiece
                    if @iReturn <> 0 GOTO E_OAError
                    select @pos = @pos + 255
                end
                select @iCurProcLine = @iCurProcLine + 1
            end
            drop table #ProcLines

            exec @iReturn = sp_OAMethod @iObjectId,
                                        'CheckIn_StoredProcedure',
                                        NULL,
                                        @sProjectName = @vchProjectName,
                                        @sSourceSafeINI = @vchSourceSafeINI,
                                        @sServerName = @vchServerName,
                                        @sDatabaseName = @vchDatabaseName,
                                        @sObjectName = @vchObjectName,
                                        @sComment = @vchComment,
                                        @sLoginName = @vchLoginName,
                                        @sPassword = @vchPassword,
                                        @iVCSFlags = @iVCSFlags,
                                        @iActionFlag = @iActionFlag,
                                        @sStream = ''
        end

        if @iReturn <> 0 GOTO E_OAError

        if @iActionFlag = 1
        begin
            commit tran compile_all
            if @@error <> 0 GOTO E_Compile_Fail
        end

    end

CleanUp:
    return

E_Compile_Fail:
    declare @lerror int
    select @lerror = @@error
    rollback tran compile_all
    RAISERROR (@lerror,16,-1)
    goto CleanUp

E_OAError:
    if @iActionFlag = 1 rollback tran compile_all
    exec dbo.dt_displayoaerror @iObjectId, @iReturn
    goto CleanUp



GO
-- ===== SQL_STORED_PROCEDURE dbo.dt_checkinobject_u
create proc dbo.dt_checkinobject_u
    @chObjectType  char(4),
    @vchObjectName nvarchar(255),
    @vchComment    nvarchar(255)='',
    @vchLoginName  nvarchar(255),
    @vchPassword   nvarchar(255)='',
    @iVCSFlags     int = 0,
    @iActionFlag   int = 0,   /* 0 => AddFile, 1 => CheckIn */
    @txStream1     Text = '', /* There is a bug that if items are NULL they do not pass to OLE servers */
    @txStream2     Text = '',
    @txStream3     Text = ''


as

set nocount on

declare @iReturn int
declare @iObjectId int
select @iObjectId = 0

declare @VSSGUID nvarchar(100)
select @VSSGUID = N'SQLVersionControl.VCS_SQL'


declare @iPropertyObjectId int
select @iPropertyObjectId  = 0

    select @iPropertyObjectId = (select objectid from dbo.dtproperties where property = 'VCSProjectID')

    declare @vchProjectName   nvarchar(255)
    declare @vchSourceSafeINI nvarchar(255)
    declare @vchServerName    nvarchar(255)
    declare @vchDatabaseName  nvarchar(255)
    exec dbo.dt_getpropertiesbyid_vcs_u @iPropertyObjectId, 'VCSProject',       @vchProjectName   OUT
    exec dbo.dt_getpropertiesbyid_vcs_u @iPropertyObjectId, 'VCSSourceSafeINI', @vchSourceSafeINI OUT
    exec dbo.dt_getpropertiesbyid_vcs_u @iPropertyObjectId, 'VCSSQLServer',     @vchServerName    OUT
    exec dbo.dt_getpropertiesbyid_vcs_u @iPropertyObjectId, 'VCSSQLDatabase',   @vchDatabaseName  OUT

    if @chObjectType = 'PROC'
    begin
        if @iActionFlag = 1
        begin
            /* Procedure Can have up to three streams
            Drop Stream, Create Stream, GRANT stream */

            begin tran compile_all

            /* try to compile the streams */
            exec (@txStream1)
            if @@error <> 0 GOTO E_Compile_Fail

            exec (@txStream2)
            if @@error <> 0 GOTO E_Compile_Fail

            exec (@txStream3)
            if @@error <> 0 GOTO E_Compile_Fail
        end

        exec @iReturn = sp_OACreate @VSSGUID, @iObjectId OUT
        if @iReturn <> 0 GOTO E_OAError

        if @iActionFlag = 1
        begin
            exec @iReturn = sp_OAMethod @iObjectId,
                                        N'CheckIn_StoredProcedure',
                                        NULL,
                                        @sProjectName = @vchProjectName,
                                        @sSourceSafeINI = @vchSourceSafeINI,
                                        @sServerName = @vchServerName,
                                        @sDatabaseName = @vchDatabaseName,
                                        @sObjectName = @vchObjectName,
                                        @sComment = @vchComment,
                                        @sLoginName = @vchLoginName,
                                        @sPassword = @vchPassword,
                                        @iVCSFlags = @iVCSFlags,
                                        @iActionFlag = @iActionFlag,
                                        @sStream = @txStream2
        end
        else
        begin
            declare @iStreamObjectId int
            declare @iReturnValue int

            exec @iReturn = sp_OAGetProperty @iObjectId, N'GetStreamObject', @iStreamObjectId OUT
            if @iReturn <> 0 GOTO E_OAError

            select colid, text into #ProcLines
            from syscomments
            where id = object_id(@vchObjectName)
            order by colid

            declare @iCurProcLine int
            declare @iProcLines int
            select @iCurProcLine = 1
            select @iProcLines = (select count(*) from #ProcLines)
            while @iCurProcLine <= @iProcLines
            begin
                declare @pos int
                select @pos = 1
                declare @iCurLineSize int
                select @iCurLineSize = len((select text from #ProcLines where colid = @iCurProcLine))
                while @pos <= @iCurLineSize
                begin
                    declare @vchProcLinePiece nvarchar(255)
                    select @vchProcLinePiece = convert(nvarchar(255),
                        substring((select text from #ProcLines where colid = @iCurProcLine),
                                  @pos, 255 ))
                    exec @iReturn = sp_OAMethod @iStreamObjectId, N'AddStream', @iReturnValue OUT, @vchProcLinePiece
                    if @iReturn <> 0 GOTO E_OAError
                    select @pos = @pos + 255
                end
                select @iCurProcLine = @iCurProcLine + 1
            end
            drop table #ProcLines

            exec @iReturn = sp_OAMethod @iObjectId,
                                        N'CheckIn_StoredProcedure',
                                        NULL,
                                        @sProjectName = @vchProjectName,
                                        @sSourceSafeINI = @vchSourceSafeINI,
                                        @sServerName = @vchServerName,
                                        @sDatabaseName = @vchDatabaseName,
                                        @sObjectName = @vchObjectName,
                                        @sComment = @vchComment,
                                        @sLoginName = @vchLoginName,
                                        @sPassword = @vchPassword,
                                        @iVCSFlags = @iVCSFlags,
                                        @iActionFlag = @iActionFlag,
                                        @sStream = ''
        end

        if @iReturn <> 0 GOTO E_OAError

        if @iActionFlag = 1
        begin
            commit tran compile_all
            if @@error <> 0 GOTO E_Compile_Fail
        end

    end

CleanUp:
    return

E_Compile_Fail:
    declare @lerror int
    select @lerror = @@error
    rollback tran compile_all
    RAISERROR (@lerror,16,-1)
    goto CleanUp

E_OAError:
    if @iActionFlag = 1 rollback tran compile_all
    exec dbo.dt_displayoaerror_u @iObjectId, @iReturn
    goto CleanUp



GO
-- ===== SQL_STORED_PROCEDURE dbo.dt_checkoutobject
create proc dbo.dt_checkoutobject
    @chObjectType  char(4),
    @vchObjectName varchar(255),
    @vchComment    varchar(255),
    @vchLoginName  varchar(255),
    @vchPassword   varchar(255),
    @iVCSFlags     int = 0,
    @iActionFlag   int = 0/* 0 => Checkout, 1 => GetLatest, 2 => UndoCheckOut */

as

set nocount on

declare @iReturn int
declare @iObjectId int
select @iObjectId =0

declare @VSSGUID varchar(100)
select @VSSGUID = 'SQLVersionControl.VCS_SQL'

declare @iReturnValue int
select @iReturnValue = 0

declare @vchTempText varchar(255)

/* this is for our strings */
declare @iStreamObjectId int
select @iStreamObjectId = 0

    declare @iPropertyObjectId int
    select @iPropertyObjectId = (select objectid from dbo.dtproperties where property = 'VCSProjectID')

    declare @vchProjectName   varchar(255)
    declare @vchSourceSafeINI varchar(255)
    declare @vchServerName    varchar(255)
    declare @vchDatabaseName  varchar(255)
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSProject',       @vchProjectName   OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSourceSafeINI', @vchSourceSafeINI OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSQLServer',     @vchServerName    OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSQLDatabase',   @vchDatabaseName  OUT

    if @chObjectType = 'PROC'
    begin
        /* Procedure Can have up to three streams
           Drop Stream, Create Stream, GRANT stream */

        exec @iReturn = sp_OACreate @VSSGUID, @iObjectId OUT

        if @iReturn <> 0 GOTO E_OAError

        exec @iReturn = sp_OAMethod @iObjectId,
                                    'CheckOut_StoredProcedure',
                                    NULL,
                                    @sProjectName = @vchProjectName,
                                    @sSourceSafeINI = @vchSourceSafeINI,
                                    @sObjectName = @vchObjectName,
                                    @sServerName = @vchServerName,
                                    @sDatabaseName = @vchDatabaseName,
                                    @sComment = @vchComment,
                                    @sLoginName = @vchLoginName,
                                    @sPassword = @vchPassword,
                                    @iVCSFlags = @iVCSFlags,
                                    @iActionFlag = @iActionFlag

        if @iReturn <> 0 GOTO E_OAError


        exec @iReturn = sp_OAGetProperty @iObjectId, 'GetStreamObject', @iStreamObjectId OUT

        if @iReturn <> 0 GOTO E_OAError

        create table #commenttext (id int identity, sourcecode varchar(255))


        select @vchTempText = 'STUB'
        while @vchTempText IS NOT NULL
        begin
            exec @iReturn = sp_OAMethod @iStreamObjectId, 'GetStream', @iReturnValue OUT, @vchTempText OUT
            if @iReturn <> 0 GOTO E_OAError

            if (@vchTempText IS NOT NULL) insert into #commenttext (sourcecode) select @vchTempText
        end

        select 'VCS'=sourcecode from #commenttext order by id
        select 'SQL'=text from syscomments where id = object_id(@vchObjectName) order by colid

    end

CleanUp:
    return

E_OAError:
    exec dbo.dt_displayoaerror @iObjectId, @iReturn
    GOTO CleanUp



GO
-- ===== SQL_STORED_PROCEDURE dbo.dt_checkoutobject_u
create proc dbo.dt_checkoutobject_u
    @chObjectType  char(4),
    @vchObjectName nvarchar(255),
    @vchComment    nvarchar(255),
    @vchLoginName  nvarchar(255),
    @vchPassword   nvarchar(255),
    @iVCSFlags     int = 0,
    @iActionFlag   int = 0/* 0 => Checkout, 1 => GetLatest, 2 => UndoCheckOut */

as

set nocount on

declare @iReturn int
declare @iObjectId int
select @iObjectId =0

declare @VSSGUID nvarchar(100)
select @VSSGUID = N'SQLVersionControl.VCS_SQL'

declare @iReturnValue int
select @iReturnValue = 0

declare @vchTempText nvarchar(255)

/* this is for our strings */
declare @iStreamObjectId int
select @iStreamObjectId = 0

    declare @iPropertyObjectId int
    select @iPropertyObjectId = (select objectid from dbo.dtproperties where property = 'VCSProjectID')

    declare @vchProjectName   nvarchar(255)
    declare @vchSourceSafeINI nvarchar(255)
    declare @vchServerName    nvarchar(255)
    declare @vchDatabaseName  nvarchar(255)
    exec dbo.dt_getpropertiesbyid_vcs_u @iPropertyObjectId, 'VCSProject',       @vchProjectName   OUT
    exec dbo.dt_getpropertiesbyid_vcs_u @iPropertyObjectId, 'VCSSourceSafeINI', @vchSourceSafeINI OUT
    exec dbo.dt_getpropertiesbyid_vcs_u @iPropertyObjectId, 'VCSSQLServer',     @vchServerName    OUT
    exec dbo.dt_getpropertiesbyid_vcs_u @iPropertyObjectId, 'VCSSQLDatabase',   @vchDatabaseName  OUT

    if @chObjectType = 'PROC'
    begin
        /* Procedure Can have up to three streams
           Drop Stream, Create Stream, GRANT stream */

        exec @iReturn = sp_OACreate @VSSGUID, @iObjectId OUT

        if @iReturn <> 0 GOTO E_OAError

        exec @iReturn = sp_OAMethod @iObjectId,
                                    N'CheckOut_StoredProcedure',
                                    NULL,
                                    @sProjectName = @vchProjectName,
                                    @sSourceSafeINI = @vchSourceSafeINI,
                                    @sObjectName = @vchObjectName,
                                    @sServerName = @vchServerName,
                                    @sDatabaseName = @vchDatabaseName,
                                    @sComment = @vchComment,
                                    @sLoginName = @vchLoginName,
                                    @sPassword = @vchPassword,
                                    @iVCSFlags = @iVCSFlags,
                                    @iActionFlag = @iActionFlag

        if @iReturn <> 0 GOTO E_OAError


        exec @iReturn = sp_OAGetProperty @iObjectId, N'GetStreamObject', @iStreamObjectId OUT

        if @iReturn <> 0 GOTO E_OAError

        create table #commenttext (id int identity, sourcecode nvarchar(255))


        select @vchTempText = N'STUB'
        while @vchTempText IS NOT NULL
        begin
            exec @iReturn = sp_OAMethod @iStreamObjectId, N'GetStream', @iReturnValue OUT, @vchTempText OUT
            if @iReturn <> 0 GOTO E_OAError

            if (@vchTempText IS NOT NULL) insert into #commenttext (sourcecode) select @vchTempText
        end

        select N'VCS'=sourcecode from #commenttext order by id
        select N'SQL'=text from syscomments where id = object_id(@vchObjectName) order by colid

    end

CleanUp:
    return

E_OAError:
    exec dbo.dt_displayoaerror_u @iObjectId, @iReturn
    GOTO CleanUp



GO
-- ===== SQL_STORED_PROCEDURE dbo.dt_displayoaerror
CREATE PROCEDURE dbo.dt_displayoaerror
    @iObject int,
    @iresult int
as

set nocount on

declare @vchOutput      varchar(255)
declare @hr             int
declare @vchSource      varchar(255)
declare @vchDescription varchar(255)

    exec @hr = sp_OAGetErrorInfo @iObject, @vchSource OUT, @vchDescription OUT

    select @vchOutput = @vchSource + ': ' + @vchDescription
    raiserror (@vchOutput,16,-1)

    return


GO
-- ===== SQL_STORED_PROCEDURE dbo.dt_displayoaerror_u
CREATE PROCEDURE dbo.dt_displayoaerror_u
    @iObject int,
    @iresult int
as

set nocount on

declare @vchOutput      nvarchar(255)
declare @hr             int
declare @vchSource      nvarchar(255)
declare @vchDescription nvarchar(255)

    exec @hr = sp_OAGetErrorInfo @iObject, @vchSource OUT, @vchDescription OUT

    select @vchOutput = @vchSource + ': ' + @vchDescription
    raiserror (@vchOutput,16,-1)

    return


GO
-- ===== SQL_STORED_PROCEDURE dbo.dt_droppropertiesbyid
/*
**	Drop one or all the associated properties of an object or an attribute 
**
**	dt_dropproperties objid, null or '' -- drop all properties of the object itself
**	dt_dropproperties objid, property -- drop the property
*/
create procedure dbo.dt_droppropertiesbyid
	@id int,
	@property varchar(64)
as
	set nocount on

	if (@property is null) or (@property = '')
		delete from dbo.dtproperties where objectid=@id
	else
		delete from dbo.dtproperties 
			where objectid=@id and property=@property


GO
-- ===== SQL_STORED_PROCEDURE dbo.dt_dropuserobjectbyid
/*
**	Drop an object from the dbo.dtproperties table
*/
create procedure dbo.dt_dropuserobjectbyid
	@id int
as
	set nocount on
	delete from dbo.dtproperties where objectid=@id

GO
-- ===== SQL_STORED_PROCEDURE dbo.dt_generateansiname
/* 
**	Generate an ansi name that is unique in the dtproperties.value column 
*/ 
create procedure dbo.dt_generateansiname(@name varchar(255) output) 
as 
	declare @prologue varchar(20) 
	declare @indexstring varchar(20) 
	declare @index integer 
 
	set @prologue = 'MSDT-A-' 
	set @index = 1 
 
	while 1 = 1 
	begin 
		set @indexstring = cast(@index as varchar(20)) 
		set @name = @prologue + @indexstring 
		if not exists (select value from dtproperties where value = @name) 
			break 
		 
		set @index = @index + 1 
 
		if (@index = 10000) 
			goto TooMany 
	end 
 
Leave: 
 
	return 
 
TooMany: 
 
	set @name = 'DIAGRAM' 
	goto Leave 

GO
-- ===== SQL_STORED_PROCEDURE dbo.dt_getobjwithprop
/*
**	Retrieve the owner object(s) of a given property
*/
create procedure dbo.dt_getobjwithprop
	@property varchar(30),
	@value varchar(255)
as
	set nocount on

	if (@property is null) or (@property = '')
	begin
		raiserror('Must specify a property name.',-1,-1)
		return (1)
	end

	if (@value is null)
		select objectid id from dbo.dtproperties
			where property=@property

	else
		select objectid id from dbo.dtproperties
			where property=@property and value=@value

GO
-- ===== SQL_STORED_PROCEDURE dbo.dt_getobjwithprop_u
/*
**	Retrieve the owner object(s) of a given property
*/
create procedure dbo.dt_getobjwithprop_u
	@property varchar(30),
	@uvalue nvarchar(255)
as
	set nocount on

	if (@property is null) or (@property = '')
	begin
		raiserror('Must specify a property name.',-1,-1)
		return (1)
	end

	if (@uvalue is null)
		select objectid id from dbo.dtproperties
			where property=@property

	else
		select objectid id from dbo.dtproperties
			where property=@property and uvalue=@uvalue

GO
-- ===== SQL_STORED_PROCEDURE dbo.dt_getpropertiesbyid
/*
**	Retrieve properties by id's
**
**	dt_getproperties objid, null or '' -- retrieve all properties of the object itself
**	dt_getproperties objid, property -- retrieve the property specified
*/
create procedure dbo.dt_getpropertiesbyid
	@id int,
	@property varchar(64)
as
	set nocount on

	if (@property is null) or (@property = '')
		select property, version, value, lvalue
			from dbo.dtproperties
			where  @id=objectid
	else
		select property, version, value, lvalue
			from dbo.dtproperties
			where  @id=objectid and @property=property

GO
-- ===== SQL_STORED_PROCEDURE dbo.dt_getpropertiesbyid_u
/*
**	Retrieve properties by id's
**
**	dt_getproperties objid, null or '' -- retrieve all properties of the object itself
**	dt_getproperties objid, property -- retrieve the property specified
*/
create procedure dbo.dt_getpropertiesbyid_u
	@id int,
	@property varchar(64)
as
	set nocount on

	if (@property is null) or (@property = '')
		select property, version, uvalue, lvalue
			from dbo.dtproperties
			where  @id=objectid
	else
		select property, version, uvalue, lvalue
			from dbo.dtproperties
			where  @id=objectid and @property=property

GO
-- ===== SQL_STORED_PROCEDURE dbo.dt_getpropertiesbyid_vcs
create procedure dbo.dt_getpropertiesbyid_vcs
    @id       int,
    @property varchar(64),
    @value    varchar(255) = NULL OUT

as

    set nocount on

    select @value = (
        select value
                from dbo.dtproperties
                where @id=objectid and @property=property
                )


GO
-- ===== SQL_STORED_PROCEDURE dbo.dt_getpropertiesbyid_vcs_u
create procedure dbo.dt_getpropertiesbyid_vcs_u
    @id       int,
    @property varchar(64),
    @value    nvarchar(255) = NULL OUT

as

    set nocount on

    select @value = (
        select uvalue
                from dbo.dtproperties
                where @id=objectid and @property=property
                )


GO
-- ===== SQL_STORED_PROCEDURE dbo.dt_isundersourcecontrol
create proc dbo.dt_isundersourcecontrol
    @vchLoginName varchar(255) = '',
    @vchPassword  varchar(255) = '',
    @iWhoToo      int = 0 /* 0 => Just check project; 1 => get list of objs */

as

set nocount on

declare @iReturn int
declare @iObjectId int
select @iObjectId = 0

declare @VSSGUID varchar(100)
select @VSSGUID = 'SQLVersionControl.VCS_SQL'

declare @iReturnValue int
select @iReturnValue = 0

declare @iStreamObjectId int
select @iStreamObjectId   = 0

declare @vchTempText varchar(255)

    declare @iPropertyObjectId int
    select @iPropertyObjectId = (select objectid from dbo.dtproperties where property = 'VCSProjectID')

    declare @vchProjectName   varchar(255)
    declare @vchSourceSafeINI varchar(255)
    declare @vchServerName    varchar(255)
    declare @vchDatabaseName  varchar(255)
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSProject',       @vchProjectName   OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSourceSafeINI', @vchSourceSafeINI OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSQLServer',     @vchServerName    OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSQLDatabase',   @vchDatabaseName  OUT

    if (@vchProjectName IS NULL) or (@vchSourceSafeINI  IS NULL) or (@vchServerName IS NULL) or (@vchDatabaseName IS NULL)
    begin
        RAISERROR('Not Under Source Control',16,-1)
        return
    end

    if @iWhoToo = 1
    begin

        /* Get List of Procs in the project */
        exec @iReturn = sp_OACreate @VSSGUID, @iObjectId OUT
        if @iReturn <> 0 GOTO E_OAError

        exec @iReturn = sp_OAMethod @iObjectId,
                                    'GetListOfObjects',
                                    NULL,
                                    @vchProjectName,
                                    @vchSourceSafeINI,
                                    @vchServerName,
                                    @vchDatabaseName,
                                    @vchLoginName,
                                    @vchPassword

        if @iReturn <> 0 GOTO E_OAError

        exec @iReturn = sp_OAGetProperty @iObjectId, 'GetStreamObject', @iStreamObjectId OUT

        if @iReturn <> 0 GOTO E_OAError

        create table #ObjectList (id int identity, vchObjectlist varchar(255))

        select @vchTempText = 'STUB'
        while @vchTempText IS NOT NULL
        begin
            exec @iReturn = sp_OAMethod @iStreamObjectId, 'GetStream', @iReturnValue OUT, @vchTempText OUT
            if @iReturn <> 0 GOTO E_OAError

            if (@vchTempText IS NOT NULL) insert into #ObjectList (vchObjectlist ) select @vchTempText
        end

        select vchObjectlist from #ObjectList order by id
    end

CleanUp:
    return

E_OAError:
    exec dbo.dt_displayoaerror @iObjectId, @iReturn
    goto CleanUp



GO
-- ===== SQL_STORED_PROCEDURE dbo.dt_isundersourcecontrol_u
create proc dbo.dt_isundersourcecontrol_u
    @vchLoginName nvarchar(255) = '',
    @vchPassword  nvarchar(255) = '',
    @iWhoToo      int = 0 /* 0 => Just check project; 1 => get list of objs */

as

	set nocount on

	declare @iReturn int
	declare @iObjectId int
	select @iObjectId = 0

	declare @VSSGUID nvarchar(100)
	select @VSSGUID = N'SQLVersionControl.VCS_SQL'

	declare @iReturnValue int
	select @iReturnValue = 0

	declare @iStreamObjectId int
	select @iStreamObjectId   = 0

	declare @vchTempText nvarchar(255)

    declare @iPropertyObjectId int
    select @iPropertyObjectId = (select objectid from dbo.dtproperties where property = 'VCSProjectID')

    declare @vchProjectName   nvarchar(255)
    declare @vchSourceSafeINI nvarchar(255)
    declare @vchServerName    nvarchar(255)
    declare @vchDatabaseName  nvarchar(255)
    exec dbo.dt_getpropertiesbyid_vcs_u @iPropertyObjectId, 'VCSProject',       @vchProjectName   OUT
    exec dbo.dt_getpropertiesbyid_vcs_u @iPropertyObjectId, 'VCSSourceSafeINI', @vchSourceSafeINI OUT
    exec dbo.dt_getpropertiesbyid_vcs_u @iPropertyObjectId, 'VCSSQLServer',     @vchServerName    OUT
    exec dbo.dt_getpropertiesbyid_vcs_u @iPropertyObjectId, 'VCSSQLDatabase',   @vchDatabaseName  OUT

    if (@vchProjectName IS NULL) or (@vchSourceSafeINI  IS NULL) or (@vchServerName IS NULL) or (@vchDatabaseName IS NULL)
    begin
        RAISERROR(N'Not Under Source Control',16,-1)
        return
    end

    if @iWhoToo = 1
    begin

        /* Get List of Procs in the project */
        exec @iReturn = sp_OACreate @VSSGUID, @iObjectId OUT
        if @iReturn <> 0 GOTO E_OAError

        exec @iReturn = sp_OAMethod @iObjectId,
                                    N'GetListOfObjects',
                                    NULL,
                                    @vchProjectName,
                                    @vchSourceSafeINI,
                                    @vchServerName,
                                    @vchDatabaseName,
                                    @vchLoginName,
                                    @vchPassword

        if @iReturn <> 0 GOTO E_OAError

        exec @iReturn = sp_OAGetProperty @iObjectId, N'GetStreamObject', @iStreamObjectId OUT

        if @iReturn <> 0 GOTO E_OAError

        create table #ObjectList (id int identity, vchObjectlist nvarchar(255))

        select @vchTempText = N'STUB'
        while @vchTempText IS NOT NULL
        begin
            exec @iReturn = sp_OAMethod @iStreamObjectId, N'GetStream', @iReturnValue OUT, @vchTempText OUT
            if @iReturn <> 0 GOTO E_OAError

            if (@vchTempText IS NOT NULL) insert into #ObjectList (vchObjectlist ) select @vchTempText
        end

        select vchObjectlist from #ObjectList order by id
    end

CleanUp:
    return

E_OAError:
    exec dbo.dt_displayoaerror_u @iObjectId, @iReturn
    goto CleanUp



GO
-- ===== SQL_STORED_PROCEDURE dbo.dt_removefromsourcecontrol
create procedure dbo.dt_removefromsourcecontrol

as

    set nocount on

    declare @iPropertyObjectId int
    select @iPropertyObjectId = (select objectid from dbo.dtproperties where property = 'VCSProjectID')

    exec dbo.dt_droppropertiesbyid @iPropertyObjectId, null

    /* -1 is returned by dt_droppopertiesbyid */
    if @@error <> 0 and @@error <> -1 return 1

    return 0



GO
-- ===== SQL_STORED_PROCEDURE dbo.dt_setpropertybyid
/*
**	If the property already exists, reset the value; otherwise add property
**		id -- the id in sysobjects of the object
**		property -- the name of the property
**		value -- the text value of the property
**		lvalue -- the binary value of the property (image)
*/
create procedure dbo.dt_setpropertybyid
	@id int,
	@property varchar(64),
	@value varchar(255),
	@lvalue image
as
	set nocount on
	declare @uvalue nvarchar(255) 
	set @uvalue = convert(nvarchar(255), @value) 
	if exists (select * from dbo.dtproperties 
			where objectid=@id and property=@property)
	begin
		--
		-- bump the version count for this row as we update it
		--
		update dbo.dtproperties set value=@value, uvalue=@uvalue, lvalue=@lvalue, version=version+1
			where objectid=@id and property=@property
	end
	else
	begin
		--
		-- version count is auto-set to 0 on initial insert
		--
		insert dbo.dtproperties (property, objectid, value, uvalue, lvalue)
			values (@property, @id, @value, @uvalue, @lvalue)
	end


GO
-- ===== SQL_STORED_PROCEDURE dbo.dt_setpropertybyid_u
/*
**	If the property already exists, reset the value; otherwise add property
**		id -- the id in sysobjects of the object
**		property -- the name of the property
**		uvalue -- the text value of the property
**		lvalue -- the binary value of the property (image)
*/
create procedure dbo.dt_setpropertybyid_u
	@id int,
	@property varchar(64),
	@uvalue nvarchar(255),
	@lvalue image
as
	set nocount on
	-- 
	-- If we are writing the name property, find the ansi equivalent. 
	-- If there is no lossless translation, generate an ansi name. 
	-- 
	declare @avalue varchar(255) 
	set @avalue = null 
	if (@uvalue is not null) 
	begin 
		if (convert(nvarchar(255), convert(varchar(255), @uvalue)) = @uvalue) 
		begin 
			set @avalue = convert(varchar(255), @uvalue) 
		end 
		else 
		begin 
			if 'DtgSchemaNAME' = @property 
			begin 
				exec dbo.dt_generateansiname @avalue output 
			end 
		end 
	end 
	if exists (select * from dbo.dtproperties 
			where objectid=@id and property=@property)
	begin
		--
		-- bump the version count for this row as we update it
		--
		update dbo.dtproperties set value=@avalue, uvalue=@uvalue, lvalue=@lvalue, version=version+1
			where objectid=@id and property=@property
	end
	else
	begin
		--
		-- version count is auto-set to 0 on initial insert
		--
		insert dbo.dtproperties (property, objectid, value, uvalue, lvalue)
			values (@property, @id, @avalue, @uvalue, @lvalue)
	end

GO
-- ===== SQL_STORED_PROCEDURE dbo.dt_validateloginparams
create proc dbo.dt_validateloginparams
    @vchLoginName  varchar(255),
    @vchPassword   varchar(255)
as

set nocount on

declare @iReturn int
declare @iObjectId int
select @iObjectId =0

declare @VSSGUID varchar(100)
select @VSSGUID = 'SQLVersionControl.VCS_SQL'

    declare @iPropertyObjectId int
    select @iPropertyObjectId = (select objectid from dbo.dtproperties where property = 'VCSProjectID')

    declare @vchSourceSafeINI varchar(255)
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSourceSafeINI', @vchSourceSafeINI OUT

    exec @iReturn = sp_OACreate @VSSGUID, @iObjectId OUT
    if @iReturn <> 0 GOTO E_OAError

    exec @iReturn = sp_OAMethod @iObjectId,
                                'ValidateLoginParams',
                                NULL,
                                @sSourceSafeINI = @vchSourceSafeINI,
                                @sLoginName = @vchLoginName,
                                @sPassword = @vchPassword
    if @iReturn <> 0 GOTO E_OAError

CleanUp:
    return

E_OAError:
    exec dbo.dt_displayoaerror @iObjectId, @iReturn
    GOTO CleanUp



GO
-- ===== SQL_STORED_PROCEDURE dbo.dt_validateloginparams_u
create proc dbo.dt_validateloginparams_u
    @vchLoginName  nvarchar(255),
    @vchPassword   nvarchar(255)
as

set nocount on

declare @iReturn int
declare @iObjectId int
select @iObjectId =0

declare @VSSGUID nvarchar(100)
select @VSSGUID = N'SQLVersionControl.VCS_SQL'

    declare @iPropertyObjectId int
    select @iPropertyObjectId = (select objectid from dbo.dtproperties where property = 'VCSProjectID')

    declare @vchSourceSafeINI nvarchar(255)
    exec dbo.dt_getpropertiesbyid_vcs_u @iPropertyObjectId, 'VCSSourceSafeINI', @vchSourceSafeINI OUT

    exec @iReturn = sp_OACreate @VSSGUID, @iObjectId OUT
    if @iReturn <> 0 GOTO E_OAError

    exec @iReturn = sp_OAMethod @iObjectId,
                                N'ValidateLoginParams',
                                NULL,
                                @sSourceSafeINI = @vchSourceSafeINI,
                                @sLoginName = @vchLoginName,
                                @sPassword = @vchPassword
    if @iReturn <> 0 GOTO E_OAError

CleanUp:
    return

E_OAError:
    exec dbo.dt_displayoaerror_u @iObjectId, @iReturn
    GOTO CleanUp



GO
-- ===== SQL_STORED_PROCEDURE dbo.dt_vcsenabled
create proc dbo.dt_vcsenabled

as

set nocount on

declare @iObjectId int
select @iObjectId = 0

declare @VSSGUID varchar(100)
select @VSSGUID = 'SQLVersionControl.VCS_SQL'

    declare @iReturn int
    exec @iReturn = sp_OACreate @VSSGUID, @iObjectId OUT
    if @iReturn <> 0 raiserror('', 16, -1) /* Can't Load Helper DLLC */



GO
-- ===== SQL_STORED_PROCEDURE dbo.dt_verstamp006
/*
**	This procedure returns the version number of the stored
**    procedures used by the Microsoft Visual Database Tools.
**    Current version is 7.0.00.
*/
create procedure dbo.dt_verstamp006
as
	select 7000

GO
-- ===== SQL_STORED_PROCEDURE dbo.dt_whocheckedout
create proc dbo.dt_whocheckedout
        @chObjectType  char(4),
        @vchObjectName varchar(255),
        @vchLoginName  varchar(255),
        @vchPassword   varchar(255)

as

set nocount on

declare @iReturn int
declare @iObjectId int
select @iObjectId =0

declare @VSSGUID varchar(100)
select @VSSGUID = 'SQLVersionControl.VCS_SQL'

    declare @iPropertyObjectId int

    select @iPropertyObjectId = (select objectid from dbo.dtproperties where property = 'VCSProjectID')

    declare @vchProjectName   varchar(255)
    declare @vchSourceSafeINI varchar(255)
    declare @vchServerName    varchar(255)
    declare @vchDatabaseName  varchar(255)
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSProject',       @vchProjectName   OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSourceSafeINI', @vchSourceSafeINI OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSQLServer',     @vchServerName    OUT
    exec dbo.dt_getpropertiesbyid_vcs @iPropertyObjectId, 'VCSSQLDatabase',   @vchDatabaseName  OUT

    if @chObjectType = 'PROC'
    begin
        exec @iReturn = sp_OACreate @VSSGUID, @iObjectId OUT

        if @iReturn <> 0 GOTO E_OAError

        declare @vchReturnValue varchar(255)
        select @vchReturnValue = ''

        exec @iReturn = sp_OAMethod @iObjectId,
                                    'WhoCheckedOut',
                                    @vchReturnValue OUT,
                                    @sProjectName = @vchProjectName,
                                    @sSourceSafeINI = @vchSourceSafeINI,
                                    @sObjectName = @vchObjectName,
                                    @sServerName = @vchServerName,
                                    @sDatabaseName = @vchDatabaseName,
                                    @sLoginName = @vchLoginName,
                                    @sPassword = @vchPassword

        if @iReturn <> 0 GOTO E_OAError

        select @vchReturnValue

    end

CleanUp:
    return

E_OAError:
    exec dbo.dt_displayoaerror @iObjectId, @iReturn
    GOTO CleanUp



GO
-- ===== SQL_STORED_PROCEDURE dbo.dt_whocheckedout_u
create proc dbo.dt_whocheckedout_u
        @chObjectType  char(4),
        @vchObjectName nvarchar(255),
        @vchLoginName  nvarchar(255),
        @vchPassword   nvarchar(255)

as

set nocount on

declare @iReturn int
declare @iObjectId int
select @iObjectId =0

declare @VSSGUID nvarchar(100)
select @VSSGUID = N'SQLVersionControl.VCS_SQL'

    declare @iPropertyObjectId int

    select @iPropertyObjectId = (select objectid from dbo.dtproperties where property = 'VCSProjectID')

    declare @vchProjectName   nvarchar(255)
    declare @vchSourceSafeINI nvarchar(255)
    declare @vchServerName    nvarchar(255)
    declare @vchDatabaseName  nvarchar(255)
    exec dbo.dt_getpropertiesbyid_vcs_u @iPropertyObjectId, 'VCSProject',       @vchProjectName   OUT
    exec dbo.dt_getpropertiesbyid_vcs_u @iPropertyObjectId, 'VCSSourceSafeINI', @vchSourceSafeINI OUT
    exec dbo.dt_getpropertiesbyid_vcs_u @iPropertyObjectId, 'VCSSQLServer',     @vchServerName    OUT
    exec dbo.dt_getpropertiesbyid_vcs_u @iPropertyObjectId, 'VCSSQLDatabase',   @vchDatabaseName  OUT

    if @chObjectType = 'PROC'
    begin
        exec @iReturn = sp_OACreate @VSSGUID, @iObjectId OUT

        if @iReturn <> 0 GOTO E_OAError

        declare @vchReturnValue nvarchar(255)
        select @vchReturnValue = ''

        exec @iReturn = sp_OAMethod @iObjectId,
                                    N'WhoCheckedOut',
                                    @vchReturnValue OUT,
                                    @sProjectName = @vchProjectName,
                                    @sSourceSafeINI = @vchSourceSafeINI,
                                    @sObjectName = @vchObjectName,
                                    @sServerName = @vchServerName,
                                    @sDatabaseName = @vchDatabaseName,
                                    @sLoginName = @vchLoginName,
                                    @sPassword = @vchPassword

        if @iReturn <> 0 GOTO E_OAError

        select @vchReturnValue

    end

CleanUp:
    return

E_OAError:
    exec dbo.dt_displayoaerror_u @iObjectId, @iReturn
    GOTO CleanUp



GO
-- ===== SQL_STORED_PROCEDURE dbo.GetCustomers_Pager
CREATE PROCEDURE [dbo].[GetCustomers_Pager]
       @SearchTerm VARCHAR(100) = ''
      ,@PageIndex INT = 1
      ,@PageSize INT = 10
      ,@RecordCount INT OUTPUT
AS
BEGIN
      SET NOCOUNT ON;
      SELECT ROW_NUMBER() OVER
      (
            ORDER BY [numcli] ASC
      )AS RowNumber
      ,[numcli]
      ,[nomcli]
      ,[concli]
      ,[vilcli]
      INTO #Results
      FROM [Client]
      WHERE [nomcli] LIKE @SearchTerm + '%' OR @SearchTerm = ''
      SELECT @RecordCount = COUNT(*)
      FROM #Results
          
      SELECT * FROM #Results
      WHERE RowNumber BETWEEN(@PageIndex -1) * @PageSize + 1 AND(((@PageIndex -1) * @PageSize + 1) + @PageSize) - 1
    
      DROP TABLE #Results
END
GO
-- ===== SQL_STORED_PROCEDURE dbo.GetInterventions_Pager
CREATE PROCEDURE [dbo].[GetInterventions_Pager]
       @SearchTerm VARCHAR(100) = ''
      ,@PageIndex INT = 1
      ,@PageSize INT = 100
      ,@RecordCount INT OUTPUT
AS
BEGIN
      SET NOCOUNT ON;
      SELECT ROW_NUMBER() OVER
      (
            ORDER BY [nomsit] ASC
      )AS RowNumber
      ,[numintint]
      ,[nomsit]
      ,CASE typint WHEN 1 THEN 'Entretien' WHEN 2 THEN 'Dépannage' WHEN 3 THEN 'Devis accepté' WHEN 7 THEN 'Désenfumage' WHEN 4 THEN 'Autre' WHEN 5 THEN 'En travaux' END as typint
      ,convert(varchar(10),[datheulim],103) as datheulim
      ,nbrentsit
      ,convert(varchar(10),[datedernierevisiteentretien],103) as datedernierevisiteentretien
      ,nomzon
      ,vilsit
      ,ISNULL(adrsit,'')+' '+ISNULL(codpossit,'')+' '+ISNULL(vilsit,'') as adrsit
      ,comint
      ,comsit
      ,numdevacc
      ,telsit
      ,nomdonneur
      INTO #Results
      FROM [Intervention] I inner join [Site] S on S.cptsit = I.cptsit left join ZoneGeographique Z on Z.numzon = S.numzonsit
      LEFT JOIN Donneur D on D.donneurid = S.donneurid
      WHERE (([nomsit] LIKE  '%' + @SearchTerm + '%' OR @SearchTerm = ''))
      AND isnull(nomsit,'')<>'' 
      AND I.staint = 1
      AND datheulim >= (select datedebut from filtreclimaccessmobile where id=1)
      AND datheulim <= (select datefin from filtreclimaccessmobile where id=1)
      SELECT @RecordCount = COUNT(*)
      FROM #Results
      
      SELECT * FROM #Results
      WHERE RowNumber BETWEEN(@PageIndex -1) * @PageSize + 1 AND(((@PageIndex -1) * @PageSize + 1) + @PageSize) - 1
    
      DROP TABLE #Results
END
GO
-- ===== SQL_STORED_PROCEDURE dbo.GetInterventions1_Pager
CREATE PROCEDURE [dbo].[GetInterventions1_Pager]
       @SearchTerm VARCHAR(100) = ''
      ,@PageIndex INT = 1
      ,@PageSize INT = 100
      ,@RecordCount INT OUTPUT
AS
BEGIN
      SET NOCOUNT ON;
      SELECT ROW_NUMBER() OVER
      (
            ORDER BY [nomsit] ASC
      )AS RowNumber
      ,[numintint]
      ,[nomsit]
      ,CASE typint WHEN 1 THEN 'Entretien' WHEN 2 THEN 'Dépannage' WHEN 3 THEN 'Devis accepté' WHEN 7 THEN 'Désenfumage' WHEN 4 THEN 'Autre' WHEN 5 THEN 'En travaux' END as typint
      ,convert(varchar(10),[datheulim],103) as datheulim
      ,nbrentsit
      ,convert(varchar(10),[datedernierevisiteentretien],103) as datedernierevisiteentretien
      ,nomzon
      ,vilsit
      ,ISNULL(adrsit,'')+' '+ISNULL(codpossit,'')+' '+ISNULL(vilsit,'') as adrsit
      ,comint
      ,comsit
      ,numdevacc
      ,telsit
      ,nomdonneur
      INTO #Results
      FROM [Intervention] I inner join [Site] S on S.cptsit = I.cptsit left join ZoneGeographique Z on Z.numzon = S.numzonsit
      LEFT JOIN Donneur D on D.donneurid = S.donneurid
      WHERE [nomsit] LIKE @SearchTerm + '%' OR @SearchTerm = ''
      AND I.staint = 1
      AND datheulim >= (select datedebut from filtreclimaccessmobile where id=1)
      AND datheulim <= (select datefin from filtreclimaccessmobile where id=1)
      SELECT @RecordCount = COUNT(*)
      FROM #Results
          
      SELECT * FROM #Results
      WHERE isnull(nomsit,'')<>'' and RowNumber BETWEEN(@PageIndex -1) * @PageSize + 1 AND(((@PageIndex -1) * @PageSize + 1) + @PageSize) - 1
    
      DROP TABLE #Results
END
GO
-- ===== SQL_STORED_PROCEDURE dbo.GetInterventionsAFaireLastFourteenDays_Pager
CREATE PROCEDURE [dbo].[GetInterventionsAFaireLastFourteenDays_Pager]
       @SearchTerm VARCHAR(100) = ''
      ,@PageIndex INT = 1
      ,@PageSize INT = 100
      ,@RecordCount INT OUTPUT
AS
BEGIN
      SET NOCOUNT ON;
      SELECT ROW_NUMBER() OVER
      (
            ORDER BY [nomsit] ASC
      )AS RowNumber
      ,[numintint]
      ,[nomsit]
      ,CASE typint WHEN 1 THEN 'Entretien' WHEN 2 THEN 'Dépannage' WHEN 3 THEN 'Devis accepté' WHEN 7 THEN 'Désenfumage' WHEN 4 THEN 'Autre' WHEN 5 THEN 'En travaux' END as typint
      ,convert(varchar(10),[datheulim],103) as datheulim
      ,nbrentsit
      ,convert(varchar(10),[datedernierevisiteentretien],103) as datedernierevisiteentretien
      ,nomzon
      ,vilsit
      ,ISNULL(adrsit,'')+' '+ISNULL(codpossit,'')+' '+ISNULL(vilsit,'') as adrsit
      ,comint
      ,comsit
      ,numdevacc
      ,telsit
      ,nomdonneur
      ,CASE staint WHEN 1 THEN 'A planifier' WHEN 7 THEN 'Clôturée' WHEN 9 THEN 'Réalisée - à valider' WHEN 8 THEN 'Annulée avec accord client' WHEN 10 THEN 'Résolue par téléphone' END as staint
      ,convert(varchar(10),[datint],103) as datint
      ,convert(varchar(10),[datheuapp],102) as datheuapp
      INTO #Results
      FROM [Intervention] I inner join [Site] S on S.cptsit = I.cptsit left join ZoneGeographique Z on Z.numzon = S.numzonsit
      LEFT JOIN Donneur D on D.donneurid = S.donneurid
      WHERE (([nomsit] LIKE  '%' + @SearchTerm + '%' OR @SearchTerm = ''))
      AND isnull(nomsit,'')<>'' 
      AND I.staint = 1   
      AND I.typint not in (5,6) 
      AND datheuapp >= GETDATE()-14
      ORDER BY datheuapp desc
      SELECT @RecordCount = COUNT(*)
      FROM #Results
      
      SELECT * FROM #Results
      WHERE RowNumber BETWEEN(@PageIndex -1) * @PageSize + 1 AND(((@PageIndex -1) * @PageSize + 1) + @PageSize) - 1
    
      DROP TABLE #Results
END
GO
-- ===== SQL_STORED_PROCEDURE dbo.GetInterventionsAFaireLastSevenDays_Pager
CREATE PROCEDURE [dbo].[GetInterventionsAFaireLastSevenDays_Pager]
       @SearchTerm VARCHAR(100) = ''
      ,@PageIndex INT = 1
      ,@PageSize INT = 100
      ,@RecordCount INT OUTPUT
AS
BEGIN
      SET NOCOUNT ON;
      SELECT ROW_NUMBER() OVER
      (
            ORDER BY [nomsit] ASC
      )AS RowNumber
      ,[numintint]
      ,[nomsit]
      ,CASE typint WHEN 1 THEN 'Entretien' WHEN 2 THEN 'Dépannage' WHEN 3 THEN 'Devis accepté' WHEN 7 THEN 'Désenfumage' WHEN 4 THEN 'Autre' WHEN 5 THEN 'En travaux' END as typint
      ,convert(varchar(10),[datheulim],103) as datheulim
      ,nbrentsit
      ,convert(varchar(10),[datedernierevisiteentretien],103) as datedernierevisiteentretien
      ,nomzon
      ,vilsit
      ,ISNULL(adrsit,'')+' '+ISNULL(codpossit,'')+' '+ISNULL(vilsit,'') as adrsit
      ,comint
      ,comsit
      ,numdevacc
      ,telsit
      ,nomdonneur
      ,CASE staint WHEN 1 THEN 'A planifier' WHEN 7 THEN 'Clôturée' WHEN 9 THEN 'Réalisée - à valider' WHEN 8 THEN 'Annulée avec accord client' WHEN 10 THEN 'Résolue par téléphone' END as staint
      ,convert(varchar(10),[datint],103) as datint
      ,convert(varchar(10),[datheuapp],103) as datheuapp
      INTO #Results
      FROM [Intervention] I inner join [Site] S on S.cptsit = I.cptsit left join ZoneGeographique Z on Z.numzon = S.numzonsit
      LEFT JOIN Donneur D on D.donneurid = S.donneurid
      WHERE (([nomsit] LIKE  '%' + @SearchTerm + '%' OR @SearchTerm = ''))
      AND isnull(nomsit,'')<>'' 
      AND I.staint = 1   
      AND I.typint not in (5,6) 
      AND datheuapp >= GETDATE()-7
      ORDER BY datheuapp desc
      SELECT @RecordCount = COUNT(*)
      FROM #Results
      
      SELECT * FROM #Results
      WHERE RowNumber BETWEEN(@PageIndex -1) * @PageSize + 1 AND(((@PageIndex -1) * @PageSize + 1) + @PageSize) - 1
    
      DROP TABLE #Results
END
GO
-- ===== SQL_STORED_PROCEDURE dbo.GetInterventionsAFaireToday_Pager
CREATE PROCEDURE [dbo].[GetInterventionsAFaireToday_Pager]
       @SearchTerm VARCHAR(100) = ''
      ,@PageIndex INT = 1
      ,@PageSize INT = 100
      ,@RecordCount INT OUTPUT
AS
BEGIN
      SET NOCOUNT ON;
      SELECT ROW_NUMBER() OVER
      (
            ORDER BY [nomsit] ASC
      )AS RowNumber
      ,[numintint]
      ,[nomsit]
      ,CASE typint WHEN 1 THEN 'Entretien' WHEN 2 THEN 'Dépannage' WHEN 3 THEN 'Devis accepté' WHEN 7 THEN 'Désenfumage' WHEN 4 THEN 'Autre' WHEN 5 THEN 'En travaux' END as typint
      ,convert(varchar(10),[datheulim],103) as datheulim
      ,nbrentsit
      ,convert(varchar(10),[datedernierevisiteentretien],103) as datedernierevisiteentretien
      ,nomzon
      ,vilsit
      ,ISNULL(adrsit,'')+' '+ISNULL(codpossit,'')+' '+ISNULL(vilsit,'') as adrsit
      ,comint
      ,comsit
      ,numdevacc
      ,telsit
      ,nomdonneur
      ,CASE staint WHEN 1 THEN 'A planifier' WHEN 7 THEN 'Clôturée' WHEN 9 THEN 'Réalisée - à valider' WHEN 8 THEN 'Annulée avec accord client' WHEN 10 THEN 'Résolue par téléphone' END as staint
      ,convert(varchar(10),[datint],103) as datint
      ,convert(varchar(10),[datheuapp],103) as datheuapp      
      INTO #Results
      FROM [Intervention] I inner join [Site] S on S.cptsit = I.cptsit left join ZoneGeographique Z on Z.numzon = S.numzonsit
      LEFT JOIN Donneur D on D.donneurid = S.donneurid
      WHERE (([nomsit] LIKE  '%' + @SearchTerm + '%' OR @SearchTerm = ''))
      AND isnull(nomsit,'')<>'' 
      AND I.staint = 1  
      AND I.typint not in (5,6)  
      AND datheuapp >= GETDATE()
      ORDER BY datheuapp desc
      SELECT @RecordCount = COUNT(*)
      FROM #Results
      
      SELECT * FROM #Results
      WHERE RowNumber BETWEEN(@PageIndex -1) * @PageSize + 1 AND(((@PageIndex -1) * @PageSize + 1) + @PageSize) - 1
    
      DROP TABLE #Results
END
GO
-- ===== SQL_STORED_PROCEDURE dbo.GetInterventionsFaites_Pager
CREATE PROCEDURE [dbo].[GetInterventionsFaites_Pager]
       @SearchTerm VARCHAR(100) = ''
      ,@PageIndex INT = 1
      ,@PageSize INT = 100
      ,@RecordCount INT OUTPUT
AS
BEGIN
      SET NOCOUNT ON;
      SELECT ROW_NUMBER() OVER
      (
            ORDER BY [nomsit] ASC
      )AS RowNumber
      ,[numintint]
      ,[nomsit]
      ,CASE typint WHEN 1 THEN 'Entretien' WHEN 2 THEN 'Dépannage' WHEN 3 THEN 'Devis accepté' WHEN 7 THEN 'Désenfumage' WHEN 4 THEN 'Autre' WHEN 5 THEN 'En travaux' END as typint
      ,convert(varchar(10),[datheulim],103) as datheulim
      ,nbrentsit
      ,convert(varchar(10),[datedernierevisiteentretien],103) as datedernierevisiteentretien
      ,nomzon
      ,vilsit
      ,ISNULL(adrsit,'')+' '+ISNULL(codpossit,'')+' '+ISNULL(vilsit,'') as adrsit
      ,comint
      ,comsit
      ,numdevacc
      ,telsit
      ,nomdonneur
      ,sigtec2
      ,CASE staint WHEN 1 THEN 'A planifier' WHEN 7 THEN 'Clôturée' WHEN 9 THEN 'Réalisée - à valider' WHEN 8 THEN 'Annulée avec accord client' WHEN 10 THEN 'Résolue par téléphone' END as staint
      ,convert(varchar(10),[datint],103) as datint
      INTO #Results
      FROM [Intervention] I inner join [Site] S on S.cptsit = I.cptsit left join ZoneGeographique Z on Z.numzon = S.numzonsit
      LEFT JOIN Donneur D on D.donneurid = S.donneurid
      WHERE (([nomsit] LIKE  '%' + @SearchTerm + '%' OR @SearchTerm = ''))
      AND isnull(nomsit,'')<>'' 
      AND I.staint in (7,9,10)      
      AND datint >= GETDATE()-7
      ORDER BY datint desc
      SELECT @RecordCount = COUNT(*)
      FROM #Results
      
      SELECT * FROM #Results
      WHERE RowNumber BETWEEN(@PageIndex -1) * @PageSize + 1 AND(((@PageIndex -1) * @PageSize + 1) + @PageSize) - 1
    
      DROP TABLE #Results
END
GO
-- ===== SQL_STORED_PROCEDURE dbo.GetInterventionsFaitesLastFourteenDays_Pager
CREATE PROCEDURE [dbo].[GetInterventionsFaitesLastFourteenDays_Pager]
       @SearchTerm VARCHAR(100) = ''
      ,@PageIndex INT = 1
      ,@PageSize INT = 100
      ,@RecordCount INT OUTPUT
AS
BEGIN
      SET NOCOUNT ON;
      SELECT ROW_NUMBER() OVER
      (
            ORDER BY [datint] DESC
      )AS RowNumber
      ,[numintint]
      ,[nomsit]
      ,CASE typint WHEN 1 THEN 'Entretien' WHEN 2 THEN 'Dépannage' WHEN 3 THEN 'Devis accepté' WHEN 7 THEN 'Désenfumage' WHEN 4 THEN 'Autre' WHEN 5 THEN 'En travaux' END as typint
      ,convert(varchar(10),[datheulim],103) as datheulim
      ,nbrentsit
      ,convert(varchar(10),[datedernierevisiteentretien],103) as datedernierevisiteentretien
      ,nomzon
      ,vilsit
      ,ISNULL(adrsit,'')+' '+ISNULL(codpossit,'')+' '+ISNULL(vilsit,'') as adrsit
      ,comint
      ,comsit
      ,numdevacc
      ,telsit
      ,nomdonneur
      ,sigtec2
      ,CASE staint WHEN 1 THEN 'A planifier' WHEN 7 THEN 'Clôturée' WHEN 9 THEN 'Réalisée - à valider' WHEN 8 THEN 'Annulée avec accord client' WHEN 10 THEN 'Résolue par téléphone' END as staint
      ,convert(varchar(10),[datint],102) as datint
      INTO #Results
      FROM [Intervention] I inner join [Site] S on S.cptsit = I.cptsit left join ZoneGeographique Z on Z.numzon = S.numzonsit
      LEFT JOIN Donneur D on D.donneurid = S.donneurid
      WHERE (([nomsit] LIKE  '%' + @SearchTerm + '%' OR @SearchTerm = ''))
      AND isnull(nomsit,'')<>'' 
      AND I.staint in (7,9,10)      
      AND datint >= GETDATE()-14
      ORDER BY datint desc
      SELECT @RecordCount = COUNT(*)
      FROM #Results
      
      SELECT * FROM #Results
      WHERE RowNumber BETWEEN(@PageIndex -1) * @PageSize + 1 AND(((@PageIndex -1) * @PageSize + 1) + @PageSize) - 1
    
      DROP TABLE #Results
END
GO
-- ===== SQL_STORED_PROCEDURE dbo.GetInterventionsFaitesLastSevenDays_Pager
CREATE PROCEDURE [dbo].[GetInterventionsFaitesLastSevenDays_Pager]
       @SearchTerm VARCHAR(100) = ''
      ,@PageIndex INT = 1
      ,@PageSize INT = 100
      ,@RecordCount INT OUTPUT
AS
BEGIN
      SET NOCOUNT ON;
      SELECT ROW_NUMBER() OVER
      (
            ORDER BY [nomsit] ASC
      )AS RowNumber
      ,[numintint]
      ,[nomsit]
      ,CASE typint WHEN 1 THEN 'Entretien' WHEN 2 THEN 'Dépannage' WHEN 3 THEN 'Devis accepté' WHEN 7 THEN 'Désenfumage' WHEN 4 THEN 'Autre' WHEN 5 THEN 'En travaux' END as typint
      ,convert(varchar(10),[datheulim],103) as datheulim
      ,nbrentsit
      ,convert(varchar(10),[datedernierevisiteentretien],103) as datedernierevisiteentretien
      ,nomzon
      ,vilsit
      ,ISNULL(adrsit,'')+' '+ISNULL(codpossit,'')+' '+ISNULL(vilsit,'') as adrsit
      ,comint
      ,comsit
      ,numdevacc
      ,telsit
      ,nomdonneur
      ,sigtec2
      ,CASE staint WHEN 1 THEN 'A planifier' WHEN 7 THEN 'Clôturée' WHEN 9 THEN 'Réalisée - à valider' WHEN 8 THEN 'Annulée avec accord client' WHEN 10 THEN 'Résolue par téléphone' END as staint
      ,convert(varchar(10),[datint],103) as datint
      INTO #Results
      FROM [Intervention] I inner join [Site] S on S.cptsit = I.cptsit left join ZoneGeographique Z on Z.numzon = S.numzonsit
      LEFT JOIN Donneur D on D.donneurid = S.donneurid
      WHERE (([nomsit] LIKE  '%' + @SearchTerm + '%' OR @SearchTerm = ''))
      AND isnull(nomsit,'')<>'' 
      AND I.staint in (7,9,10)      
      AND datint >= GETDATE()-7
      ORDER BY datint desc
      SELECT @RecordCount = COUNT(*)
      FROM #Results
      
      SELECT * FROM #Results
      WHERE RowNumber BETWEEN(@PageIndex -1) * @PageSize + 1 AND(((@PageIndex -1) * @PageSize + 1) + @PageSize) - 1
    
      DROP TABLE #Results
END
GO
-- ===== SQL_STORED_PROCEDURE dbo.GetInterventionsFaitesToday_Pager
CREATE PROCEDURE [dbo].[GetInterventionsFaitesToday_Pager]
       @SearchTerm VARCHAR(100) = ''
      ,@PageIndex INT = 1
      ,@PageSize INT = 100
      ,@RecordCount INT OUTPUT
AS
BEGIN
      SET NOCOUNT ON;
      SELECT ROW_NUMBER() OVER
      (
            ORDER BY [nomsit] ASC
      )AS RowNumber
      ,[numintint]
      ,[nomsit]
      ,CASE typint WHEN 1 THEN 'Entretien' WHEN 2 THEN 'Dépannage' WHEN 3 THEN 'Devis accepté' WHEN 7 THEN 'Désenfumage' WHEN 4 THEN 'Autre' WHEN 5 THEN 'En travaux' END as typint
      ,convert(varchar(10),[datheulim],103) as datheulim
      ,nbrentsit
      ,convert(varchar(10),[datedernierevisiteentretien],103) as datedernierevisiteentretien
      ,nomzon
      ,vilsit
      ,ISNULL(adrsit,'')+' '+ISNULL(codpossit,'')+' '+ISNULL(vilsit,'') as adrsit
      ,comint
      ,comsit
      ,numdevacc
      ,telsit
      ,nomdonneur
      ,sigtec2
      ,codint
      ,CASE staint WHEN 1 THEN 'A planifier' WHEN 7 THEN 'Clôturée' WHEN 9 THEN 'Réalisée - à valider' WHEN 8 THEN 'Annulée avec accord client' WHEN 10 THEN 'Résolue par téléphone' END as staint
      ,convert(varchar(10),[datint],103) as datint
      INTO #Results
      FROM [Intervention] I inner join [Site] S on S.cptsit = I.cptsit left join ZoneGeographique Z on Z.numzon = S.numzonsit
      LEFT JOIN Donneur D on D.donneurid = S.donneurid
      WHERE (([nomsit] LIKE  '%' + @SearchTerm + '%' OR @SearchTerm = ''))
      AND isnull(nomsit,'')<>'' 
      AND I.staint in (7,9,10)      
      AND datint >= GETDATE()
      ORDER BY datint desc
      SELECT @RecordCount = COUNT(*)
      FROM #Results
      
      SELECT * FROM #Results
      WHERE RowNumber BETWEEN(@PageIndex -1) * @PageSize + 1 AND(((@PageIndex -1) * @PageSize + 1) + @PageSize) - 1
    
      DROP TABLE #Results
END
GO
-- ===== SQL_STORED_PROCEDURE dbo.GetInterventionsParIntervenant_Pager

CREATE PROCEDURE [dbo].[GetInterventionsParIntervenant_Pager]
       @SearchTerm VARCHAR(100) = ''
      ,@CodInt VARCHAR(100) = ''       
      ,@PageIndex INT = 1
      ,@PageSize INT = 100
      ,@RecordCount INT OUTPUT
AS
BEGIN
      SET NOCOUNT ON;
    SELECT ROW_NUMBER() OVER
      (
            ORDER BY [nomsit] ASC
      )AS RowNumber
      ,[numintint]
      ,[nomsit]
      ,CASE typint WHEN 1 THEN 'Entretien' WHEN 2 THEN 'Dépannage' WHEN 3 THEN 'Devis accepté' WHEN 7 THEN 'Désenfumage' WHEN 4 THEN 'Autre' WHEN 5 THEN 'En travaux' END as typint
      ,convert(varchar(10),[datheulim],103) as datheulim
      ,nbrentsit
      ,convert(varchar(10),[datedernierevisiteentretien],103) as datedernierevisiteentretien
      ,nomzon
      ,vilsit
      ,ISNULL(adrsit,'')+' '+ISNULL(codpossit,'')+' '+ISNULL(vilsit,'') as adrsit
      ,comint
      ,comsit
      ,numdevacc
      ,telsit
      ,nomdonneur
      ,CASE staint WHEN 1 THEN 'A planifier' WHEN 7 THEN 'Clôturée' WHEN 9 THEN 'Réalisée - à valider' WHEN 8 THEN 'Annulée avec accord client' WHEN 10 THEN 'Résolue par téléphone' END as staint
      ,convert(varchar(10),[datint],103) as datint
      ,convert(varchar(10),[datheuapp],103) as datheuapp 
      INTO #Results
      FROM [Intervention] I inner join [Site] S on S.cptsit = I.cptsit left join ZoneGeographique Z on Z.numzon = S.numzonsit
      LEFT JOIN Donneur D on D.donneurid = S.donneurid
      WHERE (([nomsit] LIKE  '%' + @SearchTerm + '%' OR @SearchTerm = ''))
      AND codint = @CodInt
      AND isnull(nomsit,'')<>'' 
      AND I.staint = 1
      AND datheulim >= (select datedebut from filtreclimaccessmobile where id=1)
      AND datheulim <= (select datefin from filtreclimaccessmobile where id=1)
      SELECT @RecordCount = COUNT(*)
      FROM #Results
      
      SELECT * FROM #Results
      WHERE RowNumber BETWEEN(@PageIndex -1) * @PageSize + 1 AND(((@PageIndex -1) * @PageSize + 1) + @PageSize) - 1
    
      DROP TABLE #Results
END

GO
-- ===== SQL_STORED_PROCEDURE dbo.GetInterventionsParZone_Pager
CREATE PROCEDURE [dbo].[GetInterventionsParZone_Pager]
       @SearchTerm VARCHAR(100) = ''
      ,@NumZon VARCHAR(100) = ''       
      ,@PageIndex INT = 1
      ,@PageSize INT = 100
      ,@RecordCount INT OUTPUT
AS
BEGIN
      SET NOCOUNT ON;
      SELECT ROW_NUMBER() OVER
      (
            ORDER BY [nomsit] ASC
      )AS RowNumber
      ,[numintint]
      ,[nomsit]
      ,CASE typint WHEN 1 THEN 'Entretien' WHEN 2 THEN 'Dépannage' WHEN 3 THEN 'Devis accepté' WHEN 7 THEN 'Désenfumage' WHEN 4 THEN 'Autre' WHEN 5 THEN 'En travaux' END as typint
      ,convert(varchar(10),[datheulim],103) as datheulim
      ,nbrentsit
      ,convert(varchar(10),[datedernierevisiteentretien],103) as datedernierevisiteentretien
      ,nomzon
      ,vilsit
      ,ISNULL(adrsit,'')+' '+ISNULL(codpossit,'')+' '+ISNULL(vilsit,'') as adrsit
      ,comint
      ,comsit
      ,numdevacc
      ,telsit
      ,nomdonneur
      INTO #Results
      FROM [Intervention] I inner join [Site] S on S.cptsit = I.cptsit left join ZoneGeographique Z on Z.numzon = S.numzonsit
      LEFT JOIN Donneur D on D.donneurid = S.donneurid
      WHERE (([nomsit] LIKE  '%' + @SearchTerm + '%' OR @SearchTerm = ''))
      AND numzon = @NumZon
      AND isnull(nomsit,'')<>'' 
      AND I.staint = 1
      AND datheulim >= (select datedebut from filtreclimaccessmobile where id=1)
      AND datheulim <= (select datefin from filtreclimaccessmobile where id=1)
      SELECT @RecordCount = COUNT(*)
      FROM #Results
      
      SELECT * FROM #Results
      WHERE RowNumber BETWEEN(@PageIndex -1) * @PageSize + 1 AND(((@PageIndex -1) * @PageSize + 1) + @PageSize) - 1
    
      DROP TABLE #Results
END
GO
-- ===== SQL_STORED_PROCEDURE dbo.GetInterventionsParZoneClient_Pager
CREATE PROCEDURE [dbo].[GetInterventionsParZoneClient_Pager]
       @SearchTerm VARCHAR(100) = ''
      ,@NumZon VARCHAR(100) = ''       
      ,@PageIndex INT = 1
      ,@PageSize INT = 100
      ,@RecordCount INT OUTPUT
AS
BEGIN
      SET NOCOUNT ON;
      SELECT ROW_NUMBER() OVER
      (
            ORDER BY [nomsit] ASC
      )AS RowNumber
      ,[numintint]
      ,[nomsit]
      ,CASE typint WHEN 1 THEN 'Entretien' WHEN 2 THEN 'Dépannage' WHEN 3 THEN 'Devis accepté' WHEN 7 THEN 'Désenfumage' WHEN 4 THEN 'Autre' WHEN 5 THEN 'En travaux' END as typint
      ,convert(varchar(10),[datheulim],103) as datheulim
      ,nbrentsit
      ,convert(varchar(10),[datedernierevisiteentretien],103) as datedernierevisiteentretien
      ,nomzon
      ,vilsit
      ,ISNULL(adrsit,'')+' '+ISNULL(codpossit,'')+' '+ISNULL(vilsit,'') as adrsit
      ,comint
      ,comsit
      ,numdevacc
      ,telsit
      ,nomdonneur
      INTO #Results
      FROM [Intervention] I inner join [Site] S on S.cptsit = I.cptsit left join ZoneGeographique Z on Z.numzon = S.numzonsit
      LEFT JOIN Donneur D on D.donneurid = S.donneurid
      WHERE (([nomsit] LIKE  '%' + @SearchTerm + '%' OR @SearchTerm = ''))
      AND S.numcli = 546
      AND numzon = @NumZon
      AND isnull(nomsit,'')<>'' 
      AND I.staint = 1
      AND datheulim >= (select datedebut from filtreclimaccessmobile where id=1)
      AND datheulim <= (select datefin from filtreclimaccessmobile where id=1)
      SELECT @RecordCount = COUNT(*)
      FROM #Results
      
      SELECT * FROM #Results
      WHERE RowNumber BETWEEN(@PageIndex -1) * @PageSize + 1 AND(((@PageIndex -1) * @PageSize + 1) + @PageSize) - 1
    
      DROP TABLE #Results
END
GO
-- ===== SQL_STORED_PROCEDURE dbo.GetInterventionsParZoneFMC_Pager
CREATE PROCEDURE [dbo].[GetInterventionsParZoneFMC_Pager]
       @SearchTerm VARCHAR(100) = ''
      ,@NumZon VARCHAR(100) = ''       
      ,@PageIndex INT = 1
      ,@PageSize INT = 100
      ,@RecordCount INT OUTPUT
AS
BEGIN
      SET NOCOUNT ON;
      SELECT ROW_NUMBER() OVER
      (
            ORDER BY [nomsit] ASC
      )AS RowNumber
      ,[numintint]
      ,[nomsit]
      ,CASE typint WHEN 1 THEN 'Entretien' WHEN 2 THEN 'Dépannage' WHEN 3 THEN 'Devis accepté' WHEN 7 THEN 'Désenfumage' WHEN 4 THEN 'Autre' WHEN 5 THEN 'En travaux' END as typint
      ,convert(varchar(10),[datheulim],103) as datheulim
      ,nbrentsit
      ,convert(varchar(10),[datedernierevisiteentretien],103) as datedernierevisiteentretien
      ,nomzon
      ,vilsit
      ,ISNULL(adrsit,'')+' '+ISNULL(codpossit,'')+' '+ISNULL(vilsit,'') as adrsit
      ,comint
      ,comsit
      ,numdevacc
      ,telsit
      ,nomdonneur
      INTO #Results
      FROM [Intervention] I inner join [Site] S on S.cptsit = I.cptsit left join ZoneGeographique Z on Z.numzon = S.numzonsit
      LEFT JOIN Donneur D on D.donneurid = S.donneurid
      WHERE (([nomsit] LIKE  '%' + @SearchTerm + '%' OR @SearchTerm = ''))
	  AND codint = 'FMC'
      AND numzon = @NumZon
      AND isnull(nomsit,'')<>'' 
      AND I.staint = 1
      AND datheulim >= (select datedebut from filtreclimaccessmobile where id=1)
      AND datheulim <= (select datefin from filtreclimaccessmobile where id=1)
      SELECT @RecordCount = COUNT(*)
      FROM #Results
      
      SELECT * FROM #Results
      WHERE RowNumber BETWEEN(@PageIndex -1) * @PageSize + 1 AND(((@PageIndex -1) * @PageSize + 1) + @PageSize) - 1
    
      DROP TABLE #Results
END
GO
-- ===== SQL_STORED_PROCEDURE dbo.GetSites_Client_Pager
CREATE PROCEDURE [dbo].[GetSites_Client_Pager]
       @SearchTerm VARCHAR(100) = ''
      ,@PageIndex INT = 1
      ,@PageSize INT = 10
      ,@RecordCount INT OUTPUT
AS
BEGIN
      SET NOCOUNT ON;
      SELECT ROW_NUMBER() OVER
      (
            ORDER BY [nomsit] ASC
      )AS RowNumber
      ,[cptsit]
      ,[numsit]
      ,[nomsit]
      ,[vilsit]
      INTO #Results
      FROM [Site]
      WHERE [numzonsit]=63 AND ([nomsit] LIKE '%' + @SearchTerm + '%' OR @SearchTerm = ''
      OR [vilsit] LIKE '%' + @SearchTerm + '%')
	  
      SELECT @RecordCount = COUNT(*)
      FROM #Results
          
      SELECT * FROM #Results
      WHERE isnull(nomsit,'')<>'' and RowNumber BETWEEN(@PageIndex -1) * @PageSize + 1 AND(((@PageIndex -1) * @PageSize + 1) + @PageSize) - 1
    
      DROP TABLE #Results
END
GO
-- ===== SQL_STORED_PROCEDURE dbo.GetSites_Pager
CREATE PROCEDURE [dbo].[GetSites_Pager]
       @SearchTerm VARCHAR(100) = ''
      ,@PageIndex INT = 1
      ,@PageSize INT = 10
      ,@RecordCount INT OUTPUT
AS
BEGIN
      SET NOCOUNT ON;
      SELECT ROW_NUMBER() OVER
      (
            ORDER BY [nomsit] ASC
      )AS RowNumber
      ,[cptsit]
      ,[numsit]
      ,[nomsit]
      ,[vilsit]
      INTO #Results
      FROM [Site]
      WHERE [nomsit] LIKE '%' + @SearchTerm + '%' OR @SearchTerm = ''
      OR [vilsit] LIKE '%' + @SearchTerm + '%' 
      SELECT @RecordCount = COUNT(*)
      FROM #Results
          
      SELECT * FROM #Results
      WHERE isnull(nomsit,'')<>'' and RowNumber BETWEEN(@PageIndex -1) * @PageSize + 1 AND(((@PageIndex -1) * @PageSize + 1) + @PageSize) - 1
    
      DROP TABLE #Results
END
GO
-- ===== SQL_STORED_PROCEDURE dbo.GetSitesIntervenant_Pager
CREATE PROCEDURE [dbo].[GetSitesIntervenant_Pager]
		@CodInt VARCHAR(100)=''
      ,@SearchTerm VARCHAR(100) = ''
      ,@PageIndex INT = 1
      ,@PageSize INT = 10
      ,@RecordCount INT OUTPUT
AS
BEGIN
      SET NOCOUNT ON;
      SELECT ROW_NUMBER() OVER
      (
            ORDER BY [nomsit] ASC
      )AS RowNumber
      ,Site.[cptsit]
      ,[numsit]
      ,[nomsit]
      ,[vilsit]
      INTO #Results
      FROM [Site] left join [Intervention] on Site.cptsit = Intervention.cptsit
      WHERE ([nomsit] LIKE '%' + @SearchTerm + '%' OR @SearchTerm = ''
      OR [vilsit] LIKE '%' + @SearchTerm + '%')
	  AND (Intervention.codint = @CodInt)
	   GROUP BY  Site.[cptsit]
      ,[numsit]
      ,[nomsit]
      ,[vilsit]
      SELECT @RecordCount = COUNT(*)
      FROM #Results
          
      SELECT * FROM #Results
      WHERE isnull(nomsit,'')<>'' and RowNumber BETWEEN(@PageIndex -1) * @PageSize + 1 AND(((@PageIndex -1) * @PageSize + 1) + @PageSize) - 1
    
      DROP TABLE #Results
END
GO
-- ===== SQL_STORED_PROCEDURE dbo.GetSitesMANSUY_Client_Pager
CREATE PROCEDURE [dbo].[GetSitesMANSUY_Client_Pager]
       @SearchTerm VARCHAR(100) = ''
      ,@PageIndex INT = 1
      ,@PageSize INT = 10
      ,@RecordCount INT OUTPUT
AS
BEGIN
      SET NOCOUNT ON;
      SELECT ROW_NUMBER() OVER
      (
            ORDER BY [nomsit] ASC
      )AS RowNumber
      ,[cptsit]
      ,[numsit]
      ,[nomsit]
      ,[vilsit]
      INTO #Results
      FROM [Site]
      WHERE [numzonsit]=90 AND ([nomsit] LIKE '%' + @SearchTerm + '%' OR @SearchTerm = ''
      OR [vilsit] LIKE '%' + @SearchTerm + '%')
	  
      SELECT @RecordCount = COUNT(*)
      FROM #Results
          
      SELECT * FROM #Results
      WHERE isnull(nomsit,'')<>'' and RowNumber BETWEEN(@PageIndex -1) * @PageSize + 1 AND(((@PageIndex -1) * @PageSize + 1) + @PageSize) - 1
    
      DROP TABLE #Results
END
GO
-- ===== SQL_STORED_PROCEDURE dbo.GetSitesRC_Client_Pager
CREATE PROCEDURE [dbo].[GetSitesRC_Client_Pager]
       @SearchTerm VARCHAR(100) = ''
      ,@PageIndex INT = 1
      ,@PageSize INT = 10
      ,@RecordCount INT OUTPUT
AS
BEGIN
      SET NOCOUNT ON;
      SELECT ROW_NUMBER() OVER
      (
            ORDER BY [nomsit] ASC
      )AS RowNumber
      ,[cptsit]
      ,[numsit]
      ,[nomsit]
      ,[vilsit]
      INTO #Results
      FROM [Site]
      WHERE [numzonsit]=81 AND ([nomsit] LIKE '%' + @SearchTerm + '%' OR @SearchTerm = ''
      OR [vilsit] LIKE '%' + @SearchTerm + '%')
	  
      SELECT @RecordCount = COUNT(*)
      FROM #Results
          
      SELECT * FROM #Results
      WHERE isnull(nomsit,'')<>'' and RowNumber BETWEEN(@PageIndex -1) * @PageSize + 1 AND(((@PageIndex -1) * @PageSize + 1) + @PageSize) - 1
    
      DROP TABLE #Results
END
GO
-- ===== SQL_STORED_PROCEDURE dbo.Maj_Date_Derniere_Visite
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE Maj_Date_Derniere_Visite 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

  update  site
set     datedernierevisiteentretien = r.datint
from    site a, intervention r
WHERE   a.cptsit = r.cptsit
and r.datint in (select MAX(datint) from site 
inner join intervention on site.cptsit = intervention.cptsit 
where typint=1 and site.cptsit=a.cptsit
and staint in (6,7) 
group by site.cptsit)

END

GO
-- ===== SQL_STORED_PROCEDURE dbo.UpdateIntervention
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE UpdateIntervention 
	-- Add the parameters for the stored procedure here
	@numintint int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	UPDATE Intervention set devisafaire=0,devisfait=1 where numintint=@numintint
   
END

GO
-- ===== SQL_TRIGGER dbo.i_intervention
CREATE TRIGGER [dbo].[i_intervention]
   ON  dbo.Intervention
   AFTER INSERT
AS 
BEGIN
    SET NOCOUNT ON;
    declare @value int
    declare @numint int

    select @value=numintint,@numint=numint from inserted

    if @value is not null and @numint is null
    begin
        update intervention
        set numint=@value
        where numintint=@value
    end
END

GO
-- ===== SQL_TRIGGER dbo.InterventionStatusAfterUpdate
CREATE TRIGGER [InterventionStatusAfterUpdate] ON  dbo.Intervention
AFTER UPDATE
AS  
BEGIN
	IF UPDATE(staint)
	BEGIN
		DECLARE @numintint INT
		DECLARE @oldStaint INT
		DECLARE @newStaint INT
		SELECT @numintint=[numintint], @oldStaint=staint FROM deleted;
		SELECT @newStaint=staint FROM inserted;
		IF (@oldStaint = 1 and @newStaint <> @oldStaint) 
		BEGIN
			INSERT INTO [Intervention_Status_Changed_history]([numintint]) VALUES(@numintint)
		END
	END	
END

GO
-- ===== SQL_TRIGGER dbo.tri_ficheintervention
CREATE TRIGGER [tri_ficheintervention] ON [dbo].[FicheIntervention] 
FOR INSERT, UPDATE
AS
begin
if not update(majle)
	update intervention set majle=getdate() where numintint in (select numintint from inserted)
	update ficheintervention set majle=getdate() where numficheint in (select numficheint from inserted)
end

GO
-- ===== SQL_TRIGGER dbo.tri_majle
CREATE TRIGGER [tri_majle] ON dbo.Site 
FOR UPDATE
AS
begin
if not update(majle)
	update Site set majle=getdate() where numsit in (select numsit from inserted)
end

GO
-- ===== SQL_TRIGGER dbo.tri_majle_intervention
CREATE TRIGGER [tri_majle_intervention] ON dbo.Intervention 
FOR UPDATE
AS
begin
if not update(majle)
	update intervention set majle=getdate() where numintint in (select numintint from inserted)
end

GO
-- ===== VIEW dbo.InterventionsMobile
create view InterventionsMobile as

SELECT     dbo.Intervention.numintint, dbo.Intervention.typint, dbo.Intervention.codint, dbo.Intervention.datintpre, dbo.Intervention.heuintpre, 
                      dbo.Intervention.datint, dbo.Intervention.tpsallint, dbo.Intervention.tpsretint, dbo.Intervention.heuarrint, dbo.Intervention.heudepint, 
                      dbo.Intervention.codpan, dbo.Intervention.comint, dbo.Intervention.dirint, dbo.Intervention.refcliint, dbo.Intervention.majregsec, dbo.Client.nomcli, 
                      dbo.Site.numsit, dbo.Site.codsit, dbo.Site.nomsit, dbo.Site.typsit, dbo.Site.adrsit, dbo.Site.codpossit, dbo.Site.vilsit, dbo.Site.telsit, dbo.Site.faxsit, 
                      dbo.Site.telcencom, dbo.Site.hor_lun_ouv, dbo.Site.hor_lun_fer, dbo.Site.hor_mar_ouv, dbo.Site.hor_mar_fer, dbo.Site.hor_mer_ouv, 
                      dbo.Site.hor_mer_fer, dbo.Site.hor_jeu_ouv, dbo.Site.hor_jeu_fer, dbo.Site.hor_ven_ouv, dbo.Site.hor_ven_fer, dbo.Site.hor_sam_ouv, 
                      dbo.Site.hor_sam_fer, dbo.Site.hor_dim_ouv, dbo.Site.hor_dim_fer, dbo.Site.comsit, dbo.Site.sitsit
FROM         dbo.Intervention INNER JOIN
                      dbo.Site ON dbo.Intervention.cptsit = dbo.Site.cptsit INNER JOIN
                      dbo.Client ON dbo.Site.numcli = dbo.Client.numcli


GO
-- ===== VIEW dbo.ListeInterventionGenerale
CREATE VIEW dbo.ListeInterventionGenerale
AS
SELECT     dbo.ZoneGeographique.nomzon, dbo.Client.nomcli, dbo.Site.nomsit, dbo.Intervention.objint, dbo.Site.codpossit, dbo.Site.vilsit, dbo.Intervention.typint, dbo.Intervention.datheuapp, 
                      dbo.Intervention.datintpre, dbo.Intervention.staint, dbo.Intervention.traitepar, dbo.Client.numcli, dbo.Intervention.numintint, dbo.Site.cptsit, dbo.Site.numsit, dbo.Intervention.datint, 
                      dbo.Intervention.cheficdemint, dbo.Intervention.devisafaire, dbo.Site.numzonsit, dbo.Intervention.codint, dbo.Site.donneurid, dbo.Intervention.datheulim, dbo.Site.adrsit, dbo.Site.nbrentsit, 
                      dbo.Intervention.photofaite, dbo.Intervention.auditfait, dbo.Intervention.majregsec, dbo.Intervention.controleetancheite, dbo.Site.telsit, dbo.Devis.NomFichierDevis, dbo.Site.longitude, 
                      dbo.Site.latitude, dbo.Intervention.devisfait, dbo.Intervention.devisanepasfaire, dbo.Site.photoafaire, dbo.Site.auditafaire, dbo.Site.controleetancheiteafaire, dbo.Site.majregistresecuriteafaire, 
                      dbo.Intervention.numdevacc, dbo.Site.datedernierevisiteentretien, dbo.Site.comsit, dbo.Devis.NumeroDevis, dbo.Client.affcli, dbo.Devis.NumeroDevisInterne, dbo.Intervention.tpsallint, 
                      dbo.Intervention.tpsretint, dbo.Intervention.heuarrint, dbo.Intervention.heudepint, dbo.Intervention.nbrtecint, dbo.Intervention.sigsit, dbo.Intervention.codpan, dbo.Intervention.sigtecimg, 
                      dbo.Intervention.sigcliimg, dbo.Intervention.sigsitimg, dbo.Intervention.sigtec2, dbo.Intervention.sigcli2, dbo.Intervention.numutipre, dbo.Intervention.sigtec, dbo.Intervention.comdevis, 
                      dbo.Intervention.comtec, dbo.Site.codsit, dbo.Intervention.heuvis, dbo.Intervention.comint, dbo.Intervention.refcliint, dbo.Intervention.numerodemandesoustraitant, dbo.Intervention.comdevisinterne, 
                      dbo.Intervention.mntst, dbo.Intervention.mntfmc, dbo.Intervention.intfac
FROM         dbo.Client WITH (NOLOCK) INNER JOIN
                      dbo.Intervention WITH (NOLOCK) LEFT OUTER JOIN
                      dbo.Intervenant ON dbo.Intervention.codint = dbo.Intervenant.codint INNER JOIN
                      dbo.Site WITH (NOLOCK) ON dbo.Intervention.cptsit = dbo.Site.cptsit ON dbo.Client.numcli = dbo.Site.numcli LEFT OUTER JOIN
                      dbo.Devis WITH (NOLOCK) ON dbo.Intervention.numintint = dbo.Devis.NumeroInterventionInterne LEFT OUTER JOIN
                      dbo.ZoneGeographique WITH (NOLOCK) ON dbo.Site.numzonsit = dbo.ZoneGeographique.numzon
WHERE     (dbo.Client.affcli = 1)

GO
-- ===== VIEW dbo.ListeSite
CREATE VIEW dbo.ListeSite
AS
SELECT     dbo.Site.cptsit, dbo.Site.numsit, dbo.Site.numcli, dbo.Site.codsit, dbo.Site.nomsit, dbo.Site.nomsocsit, dbo.Site.sitsit, dbo.Site.typsit, dbo.Site.adrsit, dbo.Site.codpossit, dbo.Site.vilsit, dbo.Site.telsit,
                       dbo.Site.faxsit, dbo.Site.civres, dbo.Site.nomres, dbo.Site.preres, dbo.Site.numzonsit, dbo.Site.surven, dbo.Site.surtot, dbo.Site.nbrentsit, dbo.Site.nbrdesenfsit, dbo.Site.datdervisdes, 
                      dbo.Site.comsit, dbo.Site.telcencom, dbo.Site.datcresit, dbo.Site.demixasit, dbo.Site.mntredev, dbo.Site.indclitec, dbo.Site.indvetust, dbo.Site.indpuissance, dbo.Site.indaccessib, dbo.Site.nbrplan, 
                      dbo.Site.nbrpho, dbo.Site.allumageclim, dbo.Site.domotique, dbo.Site.accessfiltre, dbo.Site.datprisencharge, dbo.Site.misajoursecurite, dbo.Site.aspirateur, dbo.Site.hor_lun_ouv, 
                      dbo.Site.hor_lun_fer, dbo.Site.hor_mar_ouv, dbo.Site.hor_mar_fer, dbo.Site.hor_mer_ouv, dbo.Site.hor_mer_fer, dbo.Site.hor_jeu_ouv, dbo.Site.hor_jeu_fer, dbo.Site.hor_ven_ouv, 
                      dbo.Site.hor_ven_fer, dbo.Site.hor_sam_ouv, dbo.Site.hor_sam_fer, dbo.Site.hor_dim_ouv, dbo.Site.hor_dim_fer, dbo.Site.typfluid, dbo.Site.temp_entree, dbo.Site.temp_sortie, dbo.Site.numzone2, 
                      dbo.Site.numintervenant, dbo.Site.creele, dbo.Site.majle, dbo.Site.longitude, dbo.Site.latitude, dbo.Site.donneurid, dbo.Site.chemindoc, dbo.Site.datesignaturecontrat, dbo.Site.numerocontratclient, 
                      dbo.Site.commentaire, dbo.Site.photoafaire, dbo.Site.photofaite, dbo.Site.auditafaire, dbo.Site.auditfait, dbo.Site.controleetancheiteafaire, dbo.Site.controleetancheitefait, 
                      dbo.Site.majregistresecuriteafaire, dbo.Site.majregistresecuritefait, dbo.Site.montantredevancetechnique, dbo.Site.montantredevancefiltre, dbo.Site.nombrevisitetechnique, 
                      dbo.Site.nombrevisitefiltre, dbo.Site.numerocontratdesenfumage, dbo.Site.nombrevisitedesenfumage, dbo.Site.datedesenfumage, dbo.Site.montantredevancedesenfumage, 
                      dbo.Site.datedernierevisiteentretien, dbo.Site.precisiongeo, dbo.Site.datefermeture, dbo.Site.motiffermeture, dbo.Site.controleetancheiteponctuel, dbo.Site.fermeture, dbo.Client.numcli AS Expr1, 
                      dbo.Client.nomcli, dbo.Client.adrcli, dbo.Client.codposcli, dbo.Client.vilcli, dbo.Client.telcli, dbo.Client.faxcli, dbo.Client.concli, dbo.Client.melcli, dbo.Client.hormaxintcli, dbo.Client.logcli, 
                      dbo.Client.cheminpho, dbo.Client.cheminpla, dbo.Client.affcli, dbo.Client.coutheuremainoeuvre, dbo.Client.coutdeplacement, dbo.Site.TarifSousTraitDesenfum, dbo.Site.NumSousTraitDesenfum, 
                      dbo.Site.TarifSousTraitChaudiere, dbo.Site.NumSousTraitChaudiere, dbo.Site.mntredevContratChaudiere, dbo.Site.NombreContratChaudiere, dbo.Site.DateContratChaudiere, 
                      dbo.Site.NumContratChaudiere, dbo.Site.TarifSousTraitClim, dbo.Site.NumSousTraitClim, dbo.Site.NumEsabora, dbo.Site.RDV_Prendre, dbo.Site.InfosCompl, dbo.Site.Invest
FROM         dbo.Site WITH (NOLOCK) INNER JOIN
                      dbo.Client WITH (NOLOCK) ON dbo.Site.numcli = dbo.Client.numcli
WHERE     (dbo.Client.affcli = 1)

GO
-- ===== VIEW dbo.Vue_FileMaker
CREATE VIEW dbo.Vue_FileMaker
AS
SELECT     REPLACE(REPLACE(REPLACE(dbo.Site.nomsit, '''', ' ') + N', ' + REPLACE(dbo.Site.adrsit, '''', ' ') + N' ' + dbo.Site.codpossit + N' ' + REPLACE(dbo.Site.vilsit, '''', ' '), 
                      CHAR(13), ''), CHAR(10), '') AS [Adresse Site complète], dbo.Client.numcli AS [N° Client], dbo.Client.nomcli AS [Nom Client], dbo.Client.adrcli AS [Adresse Client], 
                      dbo.Client.codposcli AS [CP Client], dbo.Client.telcli AS Téléphone, dbo.Client.faxcli AS Fax, dbo.Client.vilcli AS [Ville Client], dbo.Client.concli AS Contact, 
                      dbo.Client.melcli AS Mail, dbo.Site.cptsit AS [N° Site interne], dbo.Site.numsit AS [N° Site], dbo.Site.codsit AS [Code Site], dbo.Site.nomsit AS [Nom Site], 
                      dbo.Site.sitsit AS Situation, dbo.Site.typsit AS [Type Site], dbo.Site.adrsit AS [Adresse site], dbo.Site.codpossit AS [CP Site], dbo.Site.vilsit AS Ville, 
                      dbo.Site.telsit AS [Tél. Site], dbo.Site.faxsit AS [Fax Site], dbo.Site.civres AS Civilité, dbo.Site.nomres AS [Nom responsable], dbo.Site.preres AS [Prénom responsable], 
                      dbo.Site.surven AS [Surface vente], dbo.Site.surtot AS [Surface totale], dbo.Intervention.numintint AS [N° Intervention interne], 
                      dbo.Intervention.numint AS [N° Intervention], 
                      CASE dbo.Intervention.typint WHEN 1 THEN '00FF00' WHEN 2 THEN 'FF0000' WHEN 3 THEN '0000FF' WHEN 7 THEN 'CCCCCC' WHEN 4 THEN 'EEEEEE' WHEN 5 THEN
                       'BBBBBB' END AS Couleur, 
                      CASE dbo.Intervention.typint WHEN 1 THEN 'Entretien' WHEN 2 THEN 'Dépannage' WHEN 3 THEN 'Devis accepté' WHEN 7 THEN 'Désenfumage' WHEN 4 THEN 'Autre'
                       WHEN 5 THEN 'En travaux' END AS [Type Intervention], CONVERT(VARCHAR(12), dbo.Intervention.datint, 101) AS [Date réelle], 
                      dbo.Intervention.tpsallint AS [Temps aller], dbo.Intervention.tpsretint AS [Temps retour], dbo.Intervention.heuarrint AS [Heure arrivée], 
                      dbo.Intervention.heudepint AS [Heure départ], dbo.Intervention.codpan AS [Code panne], dbo.Intervention.comint AS [Commentaire intervention], 
                      dbo.Intervention.dirint AS Directives, dbo.Intervention.datheulim AS [Planifiée le], 
                      CASE dbo.Intervention.staint WHEN - 1 THEN 'Matériel à commander' WHEN 1 THEN 'A planifier' WHEN 2 THEN 'Planifiée' WHEN 3 THEN 'Attente de matériel' WHEN 4
                       THEN 'En cours' WHEN 5 THEN 'En cours chez le sous-traitant' WHEN 6 THEN 'Effectuée en attente retour fiche intervention' WHEN 7 THEN 'Clôturée' WHEN 8 THEN 'Annulée avec accord client'
                       END AS Statut, dbo.Intervention.objint AS Objet, dbo.Site.photoafaire AS [Photo à faire], dbo.Site.auditafaire AS [Audit à faire], 
                      dbo.Intervention.majregsec AS [Mise à jour du registre de sécurité], dbo.Intervention.commajregsec AS [Commentaire Mise à jour du registre de sécurité]
FROM         dbo.Client INNER JOIN
                      dbo.Site ON dbo.Client.numcli = dbo.Site.numcli INNER JOIN
                      dbo.Intervention ON dbo.Site.cptsit = dbo.Intervention.cptsit

GO
