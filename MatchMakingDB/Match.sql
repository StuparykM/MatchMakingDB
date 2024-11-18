create table "Match"
(
	MatchID int identity(1,1)
		constraint PK_Match PRIMARY KEY CLUSTERED not null,
	PlayerOne int
		constraint FK_Match_PlayerOne REFERENCES Player(UnixID) not null,
		--constraint CK_PlayerOne_Duplicate CHECK (PlayerOne NOT LIKE PlayerTwo) has to be done in a function cannot do it in creation 
	PlayerTwo int
		constraint FK_Match_PlayerTwo REFERENCES Player(UnixID) not null,
	Winner int
		constraint CK_Match_Winner CHECK (Winner BETWEEN 1 AND 2) not null,
	GameID int
		constraint FK_Match_Game REFERENCES Game(GameID) not null,
	CharacterOne int
		constraint FK_Match_CharacterOne REFERENCES "Character"(CharacterID) not null,
	CharacterTwo int
		constraint FK_Match_CharacterTwo REFERENCES "Character"(CharacterID) not null,
	VerifiedMatchURL varchar(100) null,
		Constraint CK_Match_VerifiedURL Check (VerifiedMatchURL = null or VerifiedMatchURL like Trim(VerifiedMatchURL)),
	MatchType int
		constraint FK_Match_MatchType REFERENCES MatchType(MatchTypeID) not null,
	"Date" DateTime
		constraint CK_Match_Date CHECK ("Date" <= GETDATE()) not null,
	"Admin" int
		constraint FK_Match_PlayerAdmin REFERENCES Player(UnixID) null
)
GO

create nonclustered index IX_Match_PlayerOne
	ON "Match" (PlayerOne)
GO
create nonclustered index IX_Match_PlayerTwo
	ON "Match" (PlayerTwo)
GO
create nonclustered index IX_Match_GameID
	ON "Match" (GameID)
GO
create nonclustered index IX_Match_CharacterOne
	ON "Match" (CharacterOne)
GO
create nonclustered index IX_Match_CharacterTwo
	ON "Match" (CharacterTwo)
GO
create nonclustered index IX_Match_MatchType
	ON "Match" (MatchType)
GO
create nonclustered index IX_Match_PlayerAdmin
	ON "Match" ("Admin")
GO

create trigger TR_PreventDuplicatePlayer
	on "Match"
	For insert, update
	As
		Begin
			if @@ROWCOUNT > 0 and (Update(PlayerOne) or Update(PlayerTwo))
				Begin
					if exists (
						select * 
						from inserted
						where inserted.PlayerOne = inserted.PlayerTwo
					)
					Begin
						rollback transaction
							raiserror('Player One and Player Two cannot be the same player.',16,1)
					End
				End
		End
	Return
GO