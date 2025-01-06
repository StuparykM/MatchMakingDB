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

