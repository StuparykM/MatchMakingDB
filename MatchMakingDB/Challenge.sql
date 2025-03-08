CREATE TABLE [dbo].[Challenge]
(
	ChallengeID int identity(1,1) 
		constraint PK_Challenge primary key clustered not null,
	Challenger int not null
		Constraint FK_Challenge_Challenger references Player(PlayerUnixID),
	Opponent int not null
		Constraint FK_Challenge_Opponent references Player(PlayerUnixID),
	ChallengeDate DateTime not null
		constraint CK_Challenge_Date CHECK (ChallengeDate <= GETDATE()),
	"Status" varchar(50) not null
		constraint DF_Challenge_DefaultState Default 'Pending'
)
GO

create nonclustered index IX_Challenge_Challenger
	ON Challenge(Challenger)
GO

create nonclustered index IX_Challenge_Opponent
	ON Challenge(Opponent)
GO

create trigger TR_Challenge_PreventPKUpdate
	on "Challenge"
	For update
	As
		Begin
			if @@ROWCOUNT > 0 and (Update(ChallengeID))
					Begin
						rollback transaction
							raiserror('Cannot change Log ID',16,1)
					End
				End
	Return
GO


create trigger TR_ChallengeChangeLog_AdminCheck
on Challenge
for update
as
begin
	DECLARE @PlayerUnixID int;
	set @PlayerUnixID = Admin.PlayerUnixID;
	if update(Challenger) or update(Opponent) or update(ChallengeDate)
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

create procedure Challenge_InsertData
(@Challenger int = null, @Opponent int = null, @ChallengeDate datetime = null, @Status varchar(50) = null)
AS
	BEGIN TRY
	BEGIN TRANSACTION
		IF @Challenger IS NULL
			BEGIN
				RAISERROR('Challenger cannot be null',16,1)
				ROLLBACK TRANSACTION
				RETURN
			END
		IF @Opponent IS NULL
			BEGIN
				RAISERROR('Opponent cannot be null',16,1)
				ROLLBACK TRANSACTION
				RETURN
			END
		IF @ChallengeDate IS NULL
			BEGIN
				RAISERROR('Challenge Date cannot be null',16,1)
				ROLLBACK TRANSACTION
				RETURN
			END
		IF @Status IS NULL
			BEGIN
				RAISERROR('Challenge status cannot be null',16,1)
				ROLLBACK TRANSACTION
				RETURN
			END
		IF NOT EXISTS (SELECT * FROM Player where PlayerUnixID = @Challenger)
			BEGIN
				RAISERROR('Challenger does not exist',16,1)
				RETURN
			END
		IF NOT EXISTS (SELECT * FROM Player where PlayerUnixID = @Opponent)
			BEGIN
				RAISERROR('Opponent does not exist',16,1)
				ROLLBACK TRANSACTION
				RETURN
			END
		IF @Challenger = @Opponent 
			BEGIN
				RAISERROR('Player cannot challenge themselves',16,1)
				ROLLBACK TRANSACTION
				RETURN
			END
		IF EXISTS (SELECT * FROM "Match" WHERE PlayerOne = @Opponent or PlayerTwo = @Opponent AND "Status" = 'Pending')
			BEGIN
				RAISERROR('This player is already in a match',16,1)
				ROLLBACK TRANSACTION
				RETURN
			END
		INSERT INTO Challenge (Challenger, Opponent, ChallengeDate, "Status")
		VALUES (@Challenger, @Opponent, @ChallengeDate, @Status)
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
