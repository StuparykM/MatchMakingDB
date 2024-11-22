Create Table [dbo].[AliasChangeLog] (
	Id int identity(1,1) not null
		Constraint PK_AliasChangeLog Primary Key Clustered,
	AliasID int not null
		Constraint FK_AliasChangeLog_Alias Foreign Key
			References Alias(ID),
	"Name" varchar(50) null,
	"Primary" bit null,
	ChangeDate DateTime not null
		Constraint CK_AliasChangeLog_ChangeDate Check (ChangeDate <= getdate()),
	"Admin" int not null
		Constraint FK_AliasChangeLog_PlayerAdmin Foreign Key
			References Player(UnixID)
)
GO

Create Nonclustered Index IX_AliasChangeLog_AliasID
	On AliasChangeLog(AliasID)
GO

Create Nonclustered Index IX_AliasChangeLog_Admin
	On AliasChangeLog("Admin")
GO