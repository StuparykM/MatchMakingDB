CREATE TABLE [dbo].[GenreChangeLog]
(
	ID INT identity(1,1) NOT NULL 
		constraint PK_GenreChangeLog PRIMARY KEY clustered,
	GenreID int null
		constraint FK_GenreChangeLog_GenreID references Genre(GenreID),
	NewDescription varchar(50) null
		Constraint CK_GenreChangeLog_NewDescription Check (NewDescription like Trim(NewDescription)),
	OldDescription varchar(50) null
		Constraint CK_GenreChangeLog_OldDescription Check (OldDescription like Trim(OldDescription)),
	ChangeDate datetime not null
		constraint CK_GenreChangeLog_ChangeDate check (ChangeDate <= GETDATE()),
	"Admin" int
		constraint FK_GenreChangeLog_PlayerAdmin REFERENCES Player(PlayerUnixID) not null
)
GO
create trigger TR_GenreChangeLog_PreventPKUpdate
	on "GenreChangeLog"
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
