CREATE TABLE [dbo].[Challenge]
(
	ChallengeID int identity(1,1) 
		constraint PK_Challenge primary key clustered not null,
	Challenger int not null
		Constraint FK_Challenge_Challenger references Player(PlayerUnixID),
	Opponent int not null
		Constraint FK_Challenge_Opponent references Player(PlayerUnixID),
	ChallengeDate DateTime not null
		constraint CK_Challenge_Date CHECK (ChallengeDate <= GETDATE()),
	"Status" varchar(50) not null
		constraint DF_Challenge_DefaultState Default 'Pending'
)
GO

create nonclustered index IX_Challenge_Challenger
	ON Challenge(Challenger)
GO

create nonclustered index IX_Challenge_Opponent
	ON Challenge(Opponent)
GO


