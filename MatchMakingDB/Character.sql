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

create trigger TR_CharacterChangeLog_Update
on "Character"
for update
as 
	begin
	if @@ROWCOUNT > 0 and Update(CharacterName)
		begin
			insert into CharacterChangeLog (CharacterID, NewCharacterName, OldCharacterName, ChangeDate, AdminID)
			select deleted.CharacterID,
				   deleted.CharacterName as OldCharacterName,
				   inserted.CharacterName as NewCharacterName,
				   GetDate() as ChangeDate,
				   (select PlayerUnixID from Player where IsAdmin = 1 and PlayerUnixID = USER_ID()) as AdminID
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