create table "Character"
(
	CharacterID int identity(1,1)
		constraint PK_Character PRIMARY KEY CLUSTERED not null,
	GameID int
		constraint FK_Character_Game REFERENCES Game(GameID) not null,
	CharacterName varchar(50) not null
		Constraint CK_Character_CharacterName Check (Trim(CharacterName) != '' and CharacterName like Trim(CharacterName))
)
GO

create nonclustered index IX_Character_GameID
	ON "Character" (GameID)
GO