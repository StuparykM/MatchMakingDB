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
	AdminID int not null
		Constraint FK_AliasChangeLog_Admin foreign key
			references Admin(AdminID),
)
GO


Create Nonclustered Index IX_AliasChangeLog_AliasID
	On AliasChangeLog(AliasID)
GO

Create Nonclustered Index IX_AliasChangeLog_Admin
	On AliasChangeLog(AdminID)
GO

--create trigger TR_AliasChangeLog_PreventPKUpdate
--	on AliaschangeLog
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
