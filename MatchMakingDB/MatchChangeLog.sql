CREATE TABLE [dbo].[MatchChangeLog]
(
	ID int identity (1,1) not null
		constraint PK_MatchChangeLog primary key clustered,
	MatchID int
		constraint FK_MatchChangeLog_MatchID references "Match"(MatchID) not null,
	NewPlayerOne int
		constraint FK_MatchChangeLog_NewPlayerOne REFERENCES Player(PlayerUnixID) null,
	OldPlayerOne int
		constraint FK_MatchChangeLog_OldPlayerOne REFERENCES Player(PlayerUnixID) null,
	NewPlayerTwo int
		constraint FK_MatchChangeLog_NewPlayerTwo REFERENCES Player(PlayerUnixID) null,
	OldPlayerTwo int
		constraint FK_MatchChangeLog_OldPlayerTwo REFERENCES Player(PlayerUnixID) null,
	NewWinner int
		constraint CK_MatchChangeLog_NewWinner CHECK (NewWinner BETWEEN 1 AND 2) null,
	OldWinner int
		constraint CK_MatchChangeLog_OldWinner CHECK (OldWinner BETWEEN 1 AND 2) null,
	GameID int
		constraint FK_MatchChangeLog_Game REFERENCES Game(GameID) null,
	NewCharacterOne int
		constraint FK_MatchChangeLog_NewCharacterOne REFERENCES "Character"(CharacterID) null,
	OldCharacterOne int
		constraint FK_MatchChangeLog_OldCharacterOne REFERENCES "Character"(CharacterID) null,
	NewCharacterTwo int
		constraint FK_MatchChangeLog_NewCharacterTwo REFERENCES "Character"(CharacterID) null,
	OldCharacterTwo int
		constraint FK_MatchChangeLog_OldCharacterTwo REFERENCES "Character"(CharacterID) null,
	NewVerifiedMatchURL varchar(100) null,
		Constraint CK_MatchChangeLog_NewVerifiedURL Check (NewVerifiedMatchURL like Trim(NewVerifiedMatchURL)),
	OldVerifiedMatchURL varchar(100) null,
		Constraint CK_MatchChangeLog_OldVerifiedURL Check (OldVerifiedMatchURL like Trim(OldVerifiedMatchURL)),
	NewMatchType int
		constraint FK_MatchChangeLog_NewMatchType REFERENCES MatchType(MatchTypeID) null,
	OldMatchType int
		constraint FK_MatchChangeLog_OldMatchType REFERENCES MatchType(MatchTypeID) null,
	"NewDate" DateTime
		constraint CK_MatchChangeLog_NewDate CHECK ("NewDate" <= GETDATE()) null,
	"OldDate" DateTime
		constraint CK_MatchChangeLog_OldDate CHECK ("OldDate" <= GETDATE()) null,
	ChangeDate datetime not null
		constraint CK_MatchChangeLog_ChangeDate check (ChangeDate <= GETDATE()),
	AdminID int not null
		Constraint FK_MatchChangeLog_AdminID foreign key 
			references Admin(AdminID)
)
GO

create nonclustered index IX_MatchChangeLog_NewPlayerOne
	ON "MatchChangeLog" (NewPlayerOne)
GO
create nonclustered index IX_MatchChangeLog_NewPlayerTwo
	ON "MatchChangeLog" (NewPlayerTwo)
GO
create nonclustered index IX_MatchChangeLog_OldPlayerOne
	ON "MatchChangeLog" (OldPlayerOne)
GO
create nonclustered index IX_MatchChangeLog_OldPlayerTwo
	ON "MatchChangeLog" (OldPlayerTwo)
GO
create nonclustered index IX_MatchChangeLog_GameID
	ON "MatchChangeLog" (GameID)
GO
create nonclustered index IX_MatchChangeLog_NewCharacterOne
	ON "MatchChangeLog" (NewCharacterOne)
GO
create nonclustered index IX_MatchChangeLog_NewCharacterTwo
	ON "MatchChangeLog" (NewCharacterTwo)
GO
create nonclustered index IX_MatchChangeLog_OldCharacterOne
	ON "MatchChangeLog" (OldCharacterOne)
GO
create nonclustered index IX_MatchChangeLog_OldCharacterTwo
	ON "MatchChangeLog" (OldCharacterTwo)
GO
create nonclustered index IX_MatchChangeLog_NewMatchType
	ON "MatchChangeLog" (NewMatchType)
GO
create nonclustered index IX_MatchChangeLog_OldMatchType
	ON "MatchChangeLog" (OldMatchType)
GO
create nonclustered index IX_MatchChangeLog_PlayerAdmin
	ON "MatchChangeLog" (AdminID)
GO

create trigger TR_PreventDuplicatePlayer_MatchChangeLog
	on "MatchChangeLog"
	For insert, update
	As
		Begin
			if @@ROWCOUNT > 0 and (Update(NewPlayerOne) or Update(NewPlayerTwo))
				Begin
					if exists (
						select * 
						from inserted
						where inserted.NewPlayerOne = inserted.NewPlayerTwo
					)
					Begin
						rollback transaction
							raiserror('Player One and Player Two cannot be the same player.',16,1)
					End
				End
		End
	Return
GO

create trigger TR_MatchChangeLog_PreventPKUpdate
	on "MatchChangeLog"
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