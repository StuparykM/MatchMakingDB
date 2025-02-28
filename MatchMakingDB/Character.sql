Create Table "Character" (
	CharacterID int identity(1,1) not null
		Constraint PK_Character Primary Key Clustered,
	GameID int not null
		Constraint FK_Character_Game Foreign Key
			References Game(GameID),
	CharacterName varchar(50) not null
		Constraint CK_Character_CharacterName Check (Trim(CharacterName) != '' and CharacterName like Trim(CharacterName))
)
GO



Create Nonclustered Index IX_Character_GameID
	On "Character"(GameID)
GO

create trigger TR_Character_PreventPKUpdate
	on "Character"
	For update
	As
		Begin
			if @@ROWCOUNT > 0 and (Update(CharacterID))
					Begin
						rollback transaction
							raiserror('Cannot change Log ID',16,1)
					End
				End
	Return
GO

create trigger TR_CharacterChangeLog_AdminCheck
on Character
for update
as
begin
	DECLARE @PlayerUnixID int;
	set @PlayerUnixID = Admin.PlayerUnixID;
	if update(CharacterName)
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


create trigger TR_CharacterChangeLog_Update
on "Character"
for update
as 
	begin
	if @@ROWCOUNT > 0 and Update(CharacterName)
		begin
		declare @PlayerUnixID int;
		set @PlayerUnixID = Admin.PlayerUnixID
			insert into CharacterChangeLog (CharacterID, NewCharacterName, OldCharacterName, ChangeDate, AdminID)
			select deleted.CharacterID,
				   deleted.CharacterName as OldCharacterName,
				   inserted.CharacterName as NewCharacterName,
				   GetDate() as ChangeDate,
				   @PlayerUnixID as AdminID
				from inserted
				inner join deleted
				on inserted.CharacterID = deleted.CharacterID
				if @@ERROR <> 0 
				begin
				rollback transaction
				raiserror('Update Failed', 16,1)
				end
			end
return
end
GO

create procedure Character_InsertData
(@GameID int = null, @CharacterName varchar(50) = null)
AS
	BEGIN TRY
	BEGIN TRANSACTION
		IF @GameID IS NULL
			BEGIN
				RAISERROR('GameID cannot be null',16,1)
				ROLLBACK TRANSACTION
				RETURN
			END
		IF @CharacterName IS NULL
			BEGIN
				RAISERROR('Character Name cannot be null',16,1)
				ROLLBACK TRANSACTION
				RETURN
			END
		INSERT INTO "Character" (GameID, CharacterName)
		VALUES (@GameID, @CharacterName)
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
