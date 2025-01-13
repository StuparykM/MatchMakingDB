Create Table [dbo].[Alias] (
	AliasID int identity(1, 1) not null
		Constraint PK_Alias Primary Key Clustered,
	PlayerUnixID int not null
		Constraint FK_Alias_Player Foreign Key
			References [dbo].[Player](UnixID),
	"Name" varchar(50) not null
		Constraint CK_Alias_Name Check (Trim("Name") != '' and "Name" like Trim("Name")),
	"Primary" bit not null
		Constraint DF_Alias_Primary Default 0
)
GO

Create Nonclustered Index IX_Alias_PlayerUnixID
	On [dbo].[Alias](PlayerUnixID)
GO

Create Trigger TR_Max_One_Primary_Alias
	On [dbo].[Alias]
	For Insert, Update, Delete
	As
		Begin
			If @@ROWCOUNT > 0 and Update("Primary")
				Begin
					If (
						Select Count(*)
							From [dbo].[Alias]
							Where [dbo].[Alias]."Primary" = 1
					) > 1
						Begin
							Rollback Transaction
							RaisError('A player cannot have more than 1 primary alias.', 16, 1)
						End
				End
		End
	Return
GO

create trigger TR_Alias_PreventPKUpdate
	on "Alias"
	For update
	As
		Begin
			if @@ROWCOUNT > 0 and (Update(AliasID))
					Begin
						rollback transaction
							raiserror('Cannot change or update Alias ID of a player',16,1)
					End
				End
	Return
GO

 