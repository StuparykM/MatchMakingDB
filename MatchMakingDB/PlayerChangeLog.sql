CREATE TABLE [dbo].[PlayerChangeLog]
(
	ID int identity(1,1)
		constraint PK_PlayerChangeLog primary key clustered not null,
	PlayerUnixID int
		constraint FK_PlayerChangeLog_PlayerUnixID references Player(PlayerUnixID) not null,
	OldFirstName varchar(50) null
		Constraint CK_PlayerChangeLog_OldFirstName Check (OldFirstName like Trim(OldFirstName)),
	NewFirstName varchar(50) null
		Constraint CK_PlayerChangeLog_NewFirstName Check (NewFirstName like Trim(NewFirstName)),
	OldLastName varchar(50) null
		Constraint CK_PlayerChangeLog_OldLastName Check (OldLastName like Trim(OldLastName)),
	NewLastName varchar(50) null
		Constraint CK_PlayerChangeLog_NewLastName Check (NewLastName like Trim(NewLastName)),
	OldFullName As OldFirstName + ' ' + OldLastName,
	NewFullName As NewFirstName + ' ' + NewLastName,
	OldRegion varchar(2) not null
		Constraint CK_PlayerChangeLog_OldRegion Check (OldRegion LIKE '[A-Z][A-Z]'),
	NewRegion varchar(2) not null
		Constraint CK_PlayerChangeLog_NewRegion Check (NewRegion LIKE '[A-Z][A-Z]'),
	OldWins int null
		Constraint DF_PlayerChangeLog_OldWins Default 0
		Constraint CK_PlayerChangeLog_OldWins Check (OldWins >= 0),
	NewWins int null
		Constraint DF_PlayerChangeLog_NewWins Default 0
		Constraint CK_PlayerChangeLog_NewWins Check (NewWins >= 0),
	OldLosses int null
		Constraint DF_PlayerChangeLog_OldLosses Default 0
		Constraint CK_PlayerChangeLog_OldLosses Check (OldLosses >= 0),
	NewLosses int null
		Constraint DF_PlayerChangeLog_NewLosses Default 0
		Constraint CK_PlayerChangeLog_NewLosses Check (NewLosses >= 0),
	OldRankingScore int null
		Constraint DF_PlayerChangeLog_OldRankingScore Default 1000
		Constraint CK_PlayerChangeLog_OldRankingScore Check (OldRankingScore >= 0),
	NewRankingScore int null
		Constraint DF_PlayerChangeLog_NewRankingScore Default 1000
		Constraint CK_PlayerChangeLog_NewRankingScore Check (NewRankingScore >= 0),
	NewCreationDate DateTime null
		Constraint DF_PlayerChangeLog_NewCreationDate Default GetDate()
		Constraint CK_PlayerChangeLog_NewCreationDate Check (NewCreationDate <= GetDate()),
	OldCreationDate DateTime null
		Constraint DF_PlayerChangeLog_OldCreationDate Default GetDate()
		Constraint CK_PlayerChangeLog_OldCreationDate Check (OldCreationDate <= GetDate()),
	ChangeDate datetime not null,
	AdminID int null
		Constraint FK_PlayerChangeLog_AdminID foreign key 
			references Admin(AdminID)

)
GO


create trigger TR_PlayerChangeLog_PreventPKUpdate
	on "PlayerChangeLog"
	For update
	As
		Begin
			if @@ROWCOUNT > 0 and (Update(ID))
					Begin
						rollback transaction
							raiserror('Cannot change or update Log ID',16,1)
					End
				End
	Return
GO