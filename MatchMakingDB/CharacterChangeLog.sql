CREATE TABLE [dbo].[CharacterChangeLog]
(
	ID int identity(1,1)
		constraint PK_CharacterChangeLog primary key clustered not null,
	CharacterID int
		constraint FK_CharacterChangeLog_CharacterID references "Character"(CharacterID) not null,
	CharacterName varchar(50) null
		Constraint CK_CharacterChangeLog_CharacterName Check (CharacterName like Trim(CharacterName)),
	ChangeDate datetime not null
		constraint CK_CharacterChangeLog_ChangeDate check (ChangeDate <= getdate()),
	"Admin" int
		constraint FK_CharacterChangeLog_PlayerAdmin REFERENCES Player(UnixID) not null
)
GO


