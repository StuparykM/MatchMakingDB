CREATE TABLE [dbo].[GameChangeLog]
(
	ID int identity (1,1) not null
		constraint PK_GameChangeLog primary key clustered,
	GameID int
		constraint FK_GameChangeLog_GameID references Game(GameID),
	"NewName" varchar(50) null
		Constraint CK_GameChangeLog_NewName Check ("NewName" like Trim("NewName")),
	OldName varchar(50) null,
		Constraint CK_GameChangeLog_OldName Check (OldName like Trim(OldName)),
	GenreID int
		constraint FK_GameChangeLog_Genre REFERENCES Genre(GenreID) null,
	OldVersion varchar(50)
		constraint DF_GameChangeLog_OldVersion DEFAULT 1.0 null,
	NewVersion varchar(50)
		constraint DF_GameChangeLog_NewVersion DEFAULT 1.0 null,
	ChangeDate datetime not null
		constraint CK_GameChangeLog_ChangeDate check (ChangeDate <= GETDATE()),
	"Admin" int
		constraint FK_GameChangeLog_PlayerAdmin REFERENCES Player(PlayerUnixID) not null
)
GO

create nonclustered index IX_GameChangeLog_GameID
	ON "GameChangeLog" (GameID)
GO
create nonclustered index IX_GameChangeLog_Admin
	ON "GameChangeLog" ("Admin")
GO

create trigger TR_GameChangeLog_PreventPKUpdate
	on "GameChangeLog"
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