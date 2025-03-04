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
		constraint FK_Match_Winner REFERENCES Player(PlayerUnixID) not null,
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
	"Status" bit not null
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

create trigger TR_MatchChangeLog_AdminCheck
on Match
for update
as
begin
	DECLARE @PlayerUnixID int;
	set @PlayerUnixID = Admin.PlayerUnixID;
	if update(PlayerOne) or update(PlayerTwo) or update(Winner) or update(CharacterOne) or update(CharacterTwo) or update(VerifiedMatchURL) or update(MatchType) or update("Date")
	select *
	from Admin
	where PlayerUnixID = USER_ID(@PlayerUnixID)/*this function will need to be updated, USER_ID is depreciating in the future*/ 
if @@ERROR <> 0 
	begin
	rollback transaction
	raiserror('Do not have permissions for update',16,1)
	end
end
GO

create trigger TR_MatchChangeLog_Update
on "Match"
for update
as
begin
declare @PlayerUnixID int;
set @PlayerUnixID = Admin.PlayerUnixID
	if update(PlayerOne) or update(PlayerTwo) or update(Winner) or update(CharacterOne) or update(CharacterTwo) or update(VerifiedMatchURL) or update(MatchType) or update("Date")
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
		   @PlayerUnixID as AdminID
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

create procedure Match_InsertData
(@PlayerOne int = null, @PlayerTwo int = null, @Winner int = null, @GameID int = null, @CharacterOne int = null, @CharacterTwo int = null, @VerifiedMatchURL varchar(100) = null, @MatchType int = null, @Date datetime = null)
AS
	BEGIN TRY
		BEGIN TRANSACTION
			IF @PlayerOne IS NULL OR @PlayerTwo IS NULL
				BEGIN
					RAISERROR ('Players cannot be null', 16, 1)
					ROLLBACK TRANSACTION
				END
			IF @Winner IS NULL
				BEGIN
					RAISERROR('Winner cannot be null',16,1)
					ROLLBACK TRANSACTION
				END
			IF @GameID IS NULL
				BEGIN
					RAISERROR('Game match is played in cannot be null',16,1)
					ROLLBACK TRANSACTION
				END
			IF @CharacterOne IS NULL OR @CharacterTwo IS NULL
				BEGIN
					RAISERROR('Characters played cannot be null',16,1)
					ROLLBACK TRANSACTION
				END
			IF @MatchType IS NULL
				BEGIN 
					RAISERROR('Match Type cannot be null',16,1)
					ROLLBACK TRANSACTION
				END
			IF @Date IS NULL
				BEGIN
					RAISERROR('Date match was played cannot be null',16,1)
					ROLLBACK TRANSACTION
				END
			INSERT INTO "Match" (PlayerOne, PlayerTwo, Winner, GameID, CharacterOne, CharacterTwo, VerifiedMatchURL, MatchType, "Date")
			VALUES (@PlayerOne, @PlayerTwo, @Winner, @GameID, @CharacterOne, @CharacterTwo, @VerifiedMatchURL, @MatchType, @Date)
			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
			DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT, @ErrorLine INT
			SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE(), @ErrorLine = ERROR_LINE()
			RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState, @ErrorLine)
		END CATCH
GO

create procedure CompleteMatch
(@MatchID int = null, @WinnerID int = null)
AS
	BEGIN TRY
		BEGIN TRANSACTION
			UPDATE "Match"
			SET "Status" = 1
			WHERE MatchID = @MatchID
				UPDATE Player
				SET Wins = Wins + 1
				WHERE PlayerUnixID = @WinnerID
					UPDATE Player
					SET RankingScore = RankingScore * (SELECT Multiplier FROM MatchType JOIN "Match" as M ON M.Winner = Player.PlayerUnixID WHERE M.MatchType = MatchType.MatchTypeID)
					WHERE PlayerUnixID IN (SELECT Winner FROM "Match" WHERE Winner IS NOT NULL)
						UPDATE Player
						SET Losses = Losses + 1
						WHERE PlayerUnixID IN (SELECT PlayerUnixID FROM "Match" WHERE MatchID = @MatchID AND PlayerUnixID <> @WinnerID)
			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION
			DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT, @ErrorLine INT
			SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE(), @ErrorLine = ERROR_LINE()
			RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState, @ErrorLine)
		END CATCH
GO