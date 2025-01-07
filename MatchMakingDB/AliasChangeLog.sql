Create Table [dbo].[AliasChangeLog] (
	ID int identity(1,1) not null
		Constraint PK_AliasChangeLog Primary Key Clustered,
	AliasID int not null
		Constraint FK_AliasChangeLog_Alias Foreign Key
			References Alias(ID),
	"Name" varchar(50) null,
	"Primary" bit null,
	ChangeDate DateTime not null
		Constraint CK_AliasChangeLog_ChangeDate Check (ChangeDate <= getdate()),
	"Admin" int not null
		Constraint FK_AliasChangeLog_PlayerAdmin Foreign Key
			References Player(UnixID)
)
GO


Create Nonclustered Index IX_AliasChangeLog_AliasID
	On AliasChangeLog(AliasID)
GO

Create Nonclustered Index IX_AliasChangeLog_Admin
	On AliasChangeLog("Admin")
GO

create trigger TR_AliasChangeLog_PreventPKUpdate
	on "AliaschangeLog"
	For update
	As
		Begin
			if @@ROWCOUNT > 0 and (Update(ID))
					Begin
						rollback transaction
							raiserror('Cannot change Log ID',16,1)
					End
				End
	Return
GO

create trigger TR_AliasChangeLog_Update
on AliasChangeLog
for insert, update
as
begin

    if @@ROWCOUNT > 0 and update(AliasID)
    begin
        begin try
            merge into AliasChangeLog as target
            using (select AliasID, "Name", "Primary", GetDate() as ChangeDate, "Admin"
                   from inserted) AS Source
            on target.AliasID = Source.AliasID
            when matched then
                update set
                    "Name" = Source."Name",
                    "Primary" = Source."Primary",
                    ChangeDate = Source.ChangeDate,
                    "Admin" = Source."Admin"
            when not matched by target then
                insert (AliasID, "Name", "Primary", ChangeDate, "Admin")
                values (Source.AliasID, Source."Name", Source."Primary", Source.ChangeDate, Source."Admin");
        end try
        begin catch
            ROLLBACK TRANSACTION;
            RAISERROR ('Insert or Update Failed', 16, 1);
        end catch
    end
end;
GO

