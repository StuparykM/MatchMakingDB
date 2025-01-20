CREATE TABLE [dbo].[AdminChangeLog]
(
	ID int identity(1,1) not null
		constraint PK_AdminChangeLogID primary key clustered,
	AdminID int not null
		Constraint FK_AdminChangeLog_Admin foreign key references Admin(AdminID),
	PlayerUnixID int not null
		Constraint FK_AdminChangeLog_Player Foreign Key
			References [dbo].[Player](PlayerUnixID),
	Active bit null
		constraint DF_AdminChangeLog_Active default 1,
	CreationDate DateTime null
		Constraint DF_AdminChangeLog_CreationDate Default GetDate()
		Constraint CK_AdminChangeLog_CreationDate Check (CreationDate <= GetDate())
)
go

Create Nonclustered Index IX_AdminChangeLog_PlayerUnixID
	On [dbo].[AdminChangeLog](PlayerUnixID)
GO

Create Nonclustered Index IX_AdminChangeLog_AdminID
	On [dbo].[AdminChangeLog](AdminID)
GO

create trigger TR_AdminChangeLog_PreventPKUpdate
	on AdminChangeLog
	For update
	As
		Begin
			if @@ROWCOUNT > 0 and (Update(ID))
					Begin
						rollback transaction
							raiserror('Cannot change or update Admin Change Log ID',16,1)
					End
				End
	Return
GO