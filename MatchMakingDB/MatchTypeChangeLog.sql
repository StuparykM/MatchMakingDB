CREATE TABLE [dbo].[MatchTypeChangeLog]
(
	ID int identity(1,1)
		constraint PK_MatchTypeChangeLog primary key clustered not null,
	MatchTypeID int
		constraint FK_MatchTypeChangeLog_MatchTypeID references MatchType(MatchTypeID) not null,
	"Type" varchar(50) null
		Constraint CK_MatchTypeChangeLog_Type Check ("Type" like Trim("Type")),
	Multiplier decimal(1,1) null
		Constraint DF_MatchTypeChangeLog_Multiplier Default 1.0
		Constraint CK_MatchTypeChangeLog_Multiplier Check (Multiplier >= 0),
	ChangeDate datetime not null
		constraint CK_MatchTypeChangeLog_ChangeDate check (ChangeDate <= GETDATE()),
	"Admin" int
		constraint FK_MatchTypeChangeLog_PlayerAdmin REFERENCES Player(UnixID) not null
)
GO

create trigger TR_MatchTypeChangeLog_PreventPKUpdate
	on "MatchTypeChangeLog"
	For insert, update
	As
		Begin
			if @@ROWCOUNT > 0 and (Update(ID))
				Begin
					if exists (
						select * 
						from "MatchTypeChangeLog"
						where MatchTypeChangeLog.ID = inserted.ID
					)
					Begin
						rollback transaction
							raiserror('Cannot change or update Log ID',16,1)
					End
				End
		End
	Return
GO
