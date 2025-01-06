Create Table [dbo].[Media]
(
	ID int identity(1, 1) not null
		Constraint PK_Media Primary Key Clustered,
	PlayerUnixID int not null
		Constraint FK_Media_Player Foreign Key
			References [dbo].[Player](UnixID),
	"Url" varchar(2048) not null
		Constraint CK_Media_Url Check (Trim("Url") != '' and "Url" like Trim("Url"))
)
GO

Create Nonclustered Index IX_Media_PlayerUnixID
	On [dbo].[Media](PlayerUnixID)
GO

create trigger TR_Media_PreventPKUpdate
	on "Media"
	For update
	As
		Begin
			if @@ROWCOUNT > 0 and (Update(ID))
					Begin
						rollback transaction
							raiserror('Cannot change or update Media ID',16,1)
					End
				End
	Return
GO