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


create nonclustered index IX_Character_GameID
	ON "Character" (GameID)
GO

create trigger TR_Character_PreventPKUpdate
	on "Character"
	For insert, update
	As
		Begin
			if @@ROWCOUNT > 0 and (Update(CharacterID))
				Begin
					if exists (
						select * 
						from "Character"
						where Character.CharacterID = inserted.CharacterID
					)
					Begin
						rollback transaction
							raiserror('Cannot change or update Character ID',16,1)
					End
				End
		End
	Return
=======
Create Nonclustered Index IX_Character_GameID
	On "Character"(GameID)
>>>>>>> 02bf517e88f65c8e3639c33ad1033f780402018a
GO