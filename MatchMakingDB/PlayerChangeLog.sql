CREATE TABLE [dbo].[PlayerChangeLog]
(
	ID int identity(1,1)
		constraint PK_PlayerChangeLog primary key clustered not null,
	UnixID int
		constraint FK_PlayerChangeLog_UnixID references Player(UnixID) not null,
		FirstName varchar(50) null
		Constraint CK_PlayerChangeLog_FirstName Check (FirstName like Trim(FirstName)),
	LastName varchar(50) null
		Constraint CK_PlayerChangeLog_LastName Check (LastName like Trim(LastName)),
	FullName As FirstName + ' ' + LastName,
	Wins int null
		Constraint DF_PlayerChangeLog_Wins Default 0
		Constraint CK_PlayerChangeLog_Wins Check (Wins >= 0),
	Losses int null
		Constraint DF_PlayerChangeLog_Losses Default 0
		Constraint CK_PlayerChangeLog_Losses Check (Losses >= 0),
	RankingScore int null
		Constraint DF_PlayerChangeLog_RankingScore Default 1000
		Constraint CK_PlayerChangeLog_RankingScore Check (RankingScore >= 0),
	CreationDate DateTime null
		Constraint DF_PlayerChangeLog_CreationDate Default GetDate()
		Constraint CK_PlayerChangeLog_CreationDate Check (CreationDate <= GetDate()),
	"Admin" bit null
		Constraint DF_PlayerChangeLog_Admin Default 0,
	ChangeDate datetime not null
		constraint CK_PlayerChangeLog_ChangeDate check (ChangeDate <= GETDATE()),
	"AdminChange" int
		constraint FK_PlayerChangeLog_AdminChange REFERENCES Player(UnixID) not null
)
GO
