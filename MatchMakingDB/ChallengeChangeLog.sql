CREATE TABLE [dbo].[ChallengeChangeLog]
(
	ChallengeChangeID int identity (1,1)
		constraint PK_ChallengeChangeLog_ChallengeChangeID primary key clustered not null,
	ChallengeID int
		constraint FK_Challenge references Challenge(ChallengeID) not null,
	OldChallenger int null
		constraint FK_ChallengeChangeLog_OldChallenger references Player(PlayerUnixID),
	NewChallenger int null
		constraint FK_ChallengeChangeLog_NewChallenger references Player(PlayerUnixID),
	OldOpponent int null
		constraint FK_ChallengeChangeLog_OldOpponent references Player(PlayerUnixID),
	NewOpponent int null
		constraint FK_ChallengeChangeLog_NewOpponent references Player(PlayerUnixID),
	OldChallengeDate datetime null
		constraint CK_ChallengeChangeLog_OldChangeDate CHECK (OldChallengeDate <= GETDATE()),
	NewChallengeDate datetime null
		constraint CK_ChallengeChangeLog_NewChangeDate CHECK (NewChallengeDate <= GETDATE()),
	OldStatus varchar(50) null
		constraint DF_ChallengeChangeLog_OldDefaultState Default 'Pending',
	NewStatus varchar(50) null
		constraint DF_ChallengeChangeLog_NewDefaultState Default 'Pending',
	ChangeDate datetime not null
		constraint CK_ChallengeChangeLog_ChangeDate CHECK (ChangeDate <- GETDATE()),
	AdminID int not null
		Constraint FK_ChallengeChangeLog_Admin foreign key 
			references Admin(AdminID)
)
GO

create nonclustered index IX_ChallengeChangeLog_OldChallengerID
	ON ChallengeChangeLog(OldChallenger)
GO

create nonclustered index IX_ChallengeChangeLog_NewChallengerID
	ON ChallengeChangeLog(NewChallenger)
GO

create nonclustered index IX_ChallengeChangeLog_OldOpponentID
	ON ChallengeChangeLog(OldOpponent)
GO

create nonclustered index IX_ChallengeChangeLog_NewOpponentID
	ON ChallengeChangeLog(NewOpponent)
GO

create nonclustered index IX_CharacterChangeLog_AdminID
	on ChallengeChangeLog(AdminID)
GO

create trigger TR_ChallengeChangeLog_PreventPKUpdate
	on "ChallengeChangeLog"
	For update
	As
		Begin
			if @@ROWCOUNT > 0 and (Update(ChallengeChangeID))
					Begin
						rollback transaction
							raiserror('Cannot change Log ID',16,1)
					End
				End
	Return
GO

