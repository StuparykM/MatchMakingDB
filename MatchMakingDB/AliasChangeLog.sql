Create Table [dbo].[AliasChangeLog] (
	ID int identity(1,1) not null
		Constraint PK_AliasChangeLog Primary Key Clustered,
	AliasID int not null
		Constraint FK_AliasChangeLog_Alias Foreign Key
			References Alias(AliasID),
	OldName varchar(50) null,
	"NewName" varchar(50) null,
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

--create trigger TR_AliasChangeLog_PreventPKUpdate
--	on "AliaschangeLog"
--	For update
--	As
--		Begin
--			if @@ROWCOUNT > 0 and (Update(ID))
--					Begin
--						rollback transaction
--							raiserror('Cannot change Log ID',16,1)
--					End
--				End
--	Return
--GO

create trigger TR_AliasChangeLog_Update
on AliasChangeLog
for update
as
begin
	if @@ROWCOUNT > 0 and update(AliasID)
	begin
	insert into AliasChangeLog (AliasID, OldName, "NewName", "Primary", ChangeDate,"Admin")
	select deleted."NewName", inserted."NewName", inserted.OldName, inserted."Primary", GetDate(), inserted."Admin" from inserted
		inner join Alias on inserted.AliasID = Alias.AliasID
		inner join deleted on inserted.AliasID = deleted.AliasID
			if @@ERROR <> 0 
				begin
				rollback transaction
				raiserror ('Update failed', 16,1)
			end
		end
	return
end

--create trigger TR_AliasChangeLog_Update
--on AliasChangeLog
--for insert, update
--as
--begin

--    if @@ROWCOUNT > 0 and update(AliasID)
--    begin
--        begin try
--            merge into AliasChangeLog as target
--            using (select inserted.AliasID, a."Name", a."Primary"
--                   from Alias as a
--				   inner join inserted
--				   on Alias.AliasID = inserted.AliasID) AS Source
--            on target.AliasID = Source.AliasID
--            when matched then
--                update set
--                    target."Name" = Source."Name",
--                    target."Primary" = Source."Primary",
--                    target.ChangeDate = GetDate(),
--                    target."Admin" = "Admin"
--            when not matched by target then
--                insert (AliasID, "Name", "Primary", ChangeDate, "Admin")
--                values (Source.AliasID, Source."Name", Source."Primary");
--        end try
--        begin catch
--            ROLLBACK TRANSACTION;
--            RAISERROR ('Insert or Update Failed', 16, 1);
--        end catch
--    end
--end;
--GO