Create Table [dbo].[Player] (
	UnixID int not null
		Constraint PK_Player Primary Key Clustered
		Constraint DF_UnixID Default DateDiff(s, '1970-01-01 00:00:00', GetDate()),
	FirstName varchar(50) null
		Constraint CK_FirstName Check (FirstName = null or FirstName like Trim(FirstName)),
	LastName varchar(50) null
		Constraint CK_LastName Check (LastName = null or LastName like Trim(LastName)),
	FullName As FirstName + ' ' + LastName,
	Wins int not null
		Constraint DF_Wins Default 0
		Constraint CK_Wins Check (Wins >= 0),
	Losses int not null
		Constraint DF_Losses Default 0
		Constraint CK_Losses Check (Losses >= 0),
	RankingScore int not null
		Constraint DF_RankingScore Default 1000
		Constraint CK_RankingScore Check (RankingScore >= 0),
	CreationDate DateTime not null
		Constraint DF_CreationDate Default GetDate()
		Constraint CK_CreationDate Check (CreationDate <= GetDate()),
	"Admin" bit not null
		Constraint DF_Admin Default 0
)
GO