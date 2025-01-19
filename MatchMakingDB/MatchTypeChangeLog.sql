CREATE TABLE [dbo].[MatchTypeChangeLog]
(
	ID int identity(1,1)
		constraint PK_MatchTypeChangeLog primary key clustered not null,
	MatchTypeID int
		constraint FK_MatchTypeChangeLog_MatchTypeID references MatchType(MatchTypeID) not null,
	NewType varchar(50) null
		Constraint CK_MatchTypeChangeLog_NewType Check ("NewType" like Trim("NewType")),
	OldType varchar(50) null,
		Constraint CK_MatchTypeChangeLog_OldType Check ("OldType" like Trim("OldType")),
	NewMultiplier decimal(1,1) null
		Constraint DF_MatchTypeChangeLog_NewMultiplier Default 1.0
		Constraint CK_MatchTypeChangeLog_NewMultiplier Check (NewMultiplier >= 0),
	OldMultiplier decimal(1,1) null
		Constraint DF_MatchTypeChangeLog_OldMultiplier Default 1.0
		Constraint CK_MatchTypeChangeLog_OldMultiplier Check (OldMultiplier >= 0),
	ChangeDate datetime not null
		constraint CK_MatchTypeChangeLog_ChangeDate check (ChangeDate <= GETDATE()),
	"Admin" int
		constraint FK_MatchTypeChangeLog_PlayerAdmin REFERENCES Player(UnixID) not null
)
GO

create trigger TR_MatchTypeChangeLog_PreventPKUpdate
	on "MatchTypeChangeLog"
	For update
	As
		Begin
			if @@ROWCOUNT > 0 and (Update(ID))
					Begin
						rollback transaction
							raiserror('Cannot change or update Log ID',16,1)
					End
				End
	Return
GO
