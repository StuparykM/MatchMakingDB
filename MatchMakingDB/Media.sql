Create Table [dbo].[Media]
(
	ID int identity(1, 1) not null
		Constraint PK_Media Primary Key Clustered,
	PlayerUnixID int not null
		Constraint FK_Media_Player Foreign Key
			References [dbo].[Player](UnixID),
	"Url" varchar(2048) not null
		Constraint CK_Url Check ("Url" = null or "Url" like Trim("Url"))
)
GO

Create Nonclustered Index IX_Media_PlayerUnixID
	On [dbo].[Media](PlayerUnixID)
GO