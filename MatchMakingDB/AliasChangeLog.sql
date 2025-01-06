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
	For insert, update
	As
		Begin
			if @@ROWCOUNT > 0 and (Update(ID))
				Begin
					if exists (
						select * 
						from AliasChangeLog
						where AliasChangeLog.ID = inserted.ID
					)
					Begin
						rollback transaction
							raiserror('Cannot change or update Log ID',16,1)
					End
				End
		End
	Return
GO