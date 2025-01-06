Create Table [dbo].[CharacterChangeLog] (
	ID int identity(1,1) not null
		Constraint PK_CharacterChangeLog Primary Key Clustered,
	CharacterID int not null
		Constraint FK_CharacterChangeLog_Character Foreign Key
			References "Character"(CharacterID),
	CharacterName varchar(50) null,
	ChangeDate DateTime not null
		Constraint CK_CharacterChangeLog_ChangeDate Check (ChangeDate <= getdate()),
	"Admin" int not null
		Constraint FK_CharacterChangeLog_PlayerAdmin Foreign Key
			References Player(UnixID)
)
GO

Create Nonclustered Index IX_CharacterChangeLog_CharacterID
	On CharacterChangeLog(CharacterID)
GO

create nonclustered Index IX_CharacterChangeLog_Admin
	On CharacterChangeLog(Admin)
GO

create trigger TR_CharacterChangeLog_PreventPKUpdate
	on "CharacterChangeLog"
	For insert, update
	As
		Begin
			if @@ROWCOUNT > 0 and (Update(ID))
				Begin
					if exists (
						select * 
						from "CharacterChangeLog"
						where CharacterChangeLog.ID = inserted.ID
					)
					Begin
						rollback transaction
							raiserror('Cannot change or update Log ID',16,1)
					End
				End
		End
	Return
=======
Create Nonclustered Index IX_CharacterChangeLog_Admin
	On CharacterChangeLog("Admin")
>>>>>>> 02bf517e88f65c8e3639c33ad1033f780402018a
GO