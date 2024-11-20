CREATE TABLE [dbo].[MatchChangeLog]
(
	ID int identity (1,1) not null
		constraint PK_MatchChangeLog primary key clustered,
	MatchID int
		constraint FK_MatchChangeLog_MatchID references "Match"(MatchID) not null,
	PlayerOne int
		constraint FK_MatchChangeLog_PlayerOne REFERENCES Player(UnixID) null,
	PlayerTwo int
		constraint FK_MatchChangeLog_PlayerTwo REFERENCES Player(UnixID) null,
	Winner int
		constraint CK_MatchChangeLog_Winner CHECK (Winner BETWEEN 1 AND 2) null,
	GameID int
		constraint FK_MatchChangeLog_Game REFERENCES Game(GameID) null,
	CharacterOne int
		constraint FK_MatchChangeLog_CharacterOne REFERENCES "Character"(CharacterID) null,
	CharacterTwo int
		constraint FK_MatchChangeLog_CharacterTwo REFERENCES "Character"(CharacterID) null,
	VerifiedMatchURL varchar(100) null,
		Constraint CK_MatchChangeLog_VerifiedURL Check (VerifiedMatchURL like Trim(VerifiedMatchURL)),
	MatchType int
		constraint FK_MatchChangeLog_MatchType REFERENCES MatchType(MatchTypeID) null,
	"Date" DateTime
		constraint CK_MatchChangeLog_Date CHECK ("Date" <= GETDATE()) null,
	ChangeDate datetime not null
		constraint CK_MatchChangeLog_ChangeDate check (ChangeDate <= GETDATE()),
	"Admin" int
		constraint FK_MatchChangeLog_PlayerAdmin REFERENCES Player(UnixID) not null
)
GO

create nonclustered index IX_MatchChangeLog_PlayerOne
	ON "MatchChangeLog" (PlayerOne)
GO
create nonclustered index IX_MatchChangeLog_PlayerTwo
	ON "MatchChangeLog" (PlayerTwo)
GO
create nonclustered index IX_MatchChangeLog_GameID
	ON "MatchChangeLog" (GameID)
GO
create nonclustered index IX_MatchChangeLog_CharacterOne
	ON "MatchChangeLog" (CharacterOne)
GO
create nonclustered index IX_MatchChangeLog_CharacterTwo
	ON "MatchChangeLog" (CharacterTwo)
GO
create nonclustered index IX_MatchChangeLog_MatchType
	ON "MatchChangeLog" (MatchType)
GO
create nonclustered index IX_MatchChangeLog_PlayerAdmin
	ON "MatchChangeLog" ("Admin")
GO

create trigger TR_PreventDuplicatePlayer_MatchChangeLog
	on "MatchChangeLog"
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