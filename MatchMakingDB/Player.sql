﻿Create Table [dbo].[Player] (
	PlayerUnixID int not null
		Constraint PK_Player Primary Key Clustered
		Constraint DF_Player_UnixID Default DateDiff(s, '1970-01-01 00:00:00', GetDate()),
	FirstName varchar(50) null
		Constraint CK_Player_FirstName Check (FirstName = null or FirstName like Trim(FirstName)),
	LastName varchar(50) null
		Constraint CK_Player_LastName Check (LastName = null or LastName like Trim(LastName)),
	FullName As FirstName + ' ' + LastName,
	Region varchar(2) not null
		Constraint CK_Player_Region Check (Region LIKE '[A-Z][A-Z]'),
	Wins int not null
		Constraint DF_Player_Wins Default 0
		Constraint CK_Player_Wins Check (Wins >= 0),
	Losses int not null
		Constraint DF_Player_Losses Default 0
		Constraint CK_Player_Losses Check (Losses >= 0),
	RankingScore int not null
		Constraint DF_Player_RankingScore Default 1000
		Constraint CK_Player_RankingScore Check (RankingScore >= 0),
	CreationDate DateTime not null
		Constraint DF_Player_CreationDate Default GetDate()
		Constraint CK_Player_CreationDate Check (CreationDate <= GetDate()),
)
GO

create trigger TR_Player_PreventPKUpdate
	on "Player"
	For update
	As
		Begin
			if @@ROWCOUNT > 0 and (Update(PlayerUnixID))
					Begin
						rollback transaction
							raiserror('Cannot change or update UnixID of a player',16,1)
					End
				End
	Return
GO