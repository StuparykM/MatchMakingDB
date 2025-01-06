CREATE TABLE [dbo].[AliasChangeLog]
(
	Id INT identity(1,1) NOT NULL PRIMARY KEY clustered,
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
