create table "Match"
(
	MatchID int identity(1,1)
		constraint PK_Match PRIMARY KEY CLUSTERED not null,
	PlayerOne int
		constraint FK_Match_PlayerOne REFERENCES Player(PlayerUnixID) not null,
	PlayerTwo int
		constraint FK_Match_PlayerTwo REFERENCES Player(PlayerUnixID) not null,
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
		constraint FK_Match_PlayerAdmin REFERENCES Admin(AdminID) null
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

create trigger TR_Match_PreventPKUpdate
	on "Match"
	For  update
	As
		Begin
			if @@ROWCOUNT > 0 and (Update(MatchID))
					Begin
						rollback transaction
							raiserror('Cannot change or update MatchID of a played match',16,1)
					End
				End
	Return
GO

create trigger TR_MatchChangeLog_Update
on "Match"
for update
as
begin
	if update(PlayerOne) or update(PlayerTwo) or update(Winner) or update(CharacterOne) or update(CharacterTwo) or update(VerifiedMatchURL) or update(MatchType) or update("Date") or update("Admin")
	insert into MatchChangeLog(MatchID, GameID, NewPlayerOne, OldPlayerOne, NewPlayerTwo, OldPlayerTwo, NewWinner, OldWinner, NewCharacterOne, OldCharacterOne, NewCharacterTwo, OldCharacterTwo, NewVerifiedMatchURL, OldVerifiedMatchURL, NewDate, OldDate, ChangeDate, AdminID)
	select deleted.MatchID,
		   deleted.GameID,
		   deleted.PlayerOne as OldPlayerOne,
		   inserted.PlayerOne as NewPlayerOne,
		   deleted.PlayerTwo as OldPlayerTwo,
		   inserted.PlayerTwo as NewPlayerTwo,
		   deleted.Winner as OldWinner,
		   inserted.Winner as NewWinner,
		   deleted.CharacterOne as OldCharacterOne,
		   inserted.CharacterOne as NewCharacterOne,
		   deleted.CharacterTwo as OldCharacterTwo,
		   inserted.CharacterTwo as NewCharacterTwo,
		   deleted.VerifiedMatchURL as OldVerifiedMatchURL,
		   inserted.VerifiedMatchURL as NewVerifiedMatchURL,
		   deleted."Date" as OldDate,
		   inserted."Date" as NewDate,
		   GetDate() as ChangeDate,
		   (select PlayerUnixID from Player where IsAdmin = 1 and PlayerUnixID = USER_ID()) as AdminID
		   from deleted
		   inner join inserted
		   on deleted.MatchID = inserted.MatchID
		if @@ERROR <> 0 
			begin
				rollback transaction
				raiserror ('Update Failed',16,1)
			end
		end
	return
go

