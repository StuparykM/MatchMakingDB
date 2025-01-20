Create Table [dbo].[CharacterChangeLog] (
	ID int identity(1,1) not null
		Constraint PK_CharacterChangeLog Primary Key Clustered,
	CharacterID int not null
		Constraint FK_CharacterChangeLog_Character Foreign Key
			References "Character"(CharacterID),
	OldCharacterName varchar(50) null,
	NewCharacterName varchar(50) null,
	ChangeDate DateTime not null
		Constraint CK_CharacterChangeLog_ChangeDate Check (ChangeDate <= getdate()),
	AdminID int not null
		Constraint FK_CharacterChangeLog_Admin foreign key 
			references Admin(AdminID)
)
GO

Create Nonclustered Index IX_CharacterChangeLog_CharacterID
	On CharacterChangeLog(CharacterID)
GO

create nonclustered index IX_CharacterChangeLog_AdminID
	on CharacterChangeLog(AdminID)
Go

create trigger TR_CharacterChangeLog_PreventPKUpdate
	on "CharacterChangeLog"
	For update
	As
		Begin
			if @@ROWCOUNT > 0 and (Update(ID))
					Begin
						rollback transaction
							raiserror('Cannot change Log ID',16,1)
					End
				End
	Return
GO
