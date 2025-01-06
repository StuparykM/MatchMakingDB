CREATE TABLE [dbo].[AliasChangeLog]
(
	ID INT identity(1,1) NOT NULL PRIMARY KEY clustered,
	AliasID int not null
		constraint FK_AliasChangeLog_AliasID references Alias(ID),
	"Name" varchar(50) null
		Constraint CK_AliasChangeLog_Name Check ("Name" like Trim("Name")),
	"Primary" bit null
		Constraint DF_AliasChangeLog_Primary Default 0,
	ChangeDate datetime not null
		constraint CK_AliasChangeLog_ChangeDate check (ChangeDate <= GETDATE()),
	"Admin" int
		constraint FK_AliasChangeLog_PlayerAdmin REFERENCES Player(UnixID) not null
)
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