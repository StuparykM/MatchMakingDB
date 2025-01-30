Create Table [dbo].[Player] (
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
	IsAdmin bit not null
		constraint DF_Player_IsAdmin Default 0
)
GO

Create trigger TR_Player_PreventPKUpdate
	on "Player"
	for update
	as
		begin
			if @@rowcount > 0 and (Update(PlayerUnixID))
					begin
						rollback transaction
							raiserror('cannot change or update unixid of a player',16,1)
					end
				end
	return
go

create trigger TR_Player_InsertIntoAdmin
on Player
for insert, update
as
	begin
		insert into "Admin"(PlayerUnixID, CreationDate)
		select inserted.PlayerUnixID,
			   GetDate() as CreationDate
		from inserted
		inner join Player
		on inserted.PlayerUnixID = Player.PlayerUnixID
		where Player.IsAdmin = 1
	if @@ERROR <> 0
		begin
			rollback transaction
			raiserror('Insert or update failed',16,1)
		end
	end
return
GO

create trigger TR_PlayerChangeLog_Update
on Player
for update
as
begin
	if update(FirstName) or update(LastName) or update(FullName) or update(Region) or update(Wins) or update(Losses) or update(RankingScore) or update(CreationDate) or update(IsAdmin)
		insert into PlayerChangeLog(PlayerUnixID, OldFirstName, NewFirstName, OldLastName, NewFirstName, OldFullName, NewFullName, OldRegion, NewRegion, OldWins, NewWins, OldLosses, NewLosses, OldRankingScore, NewRankingScore, NewCreationDate, OldCreationDate, ChangeDate, AdminID)
			select deleted.PlayerUnixID,
				   deleted.FirstName as OldFirstName,
				   inserted.FirstName as NewFirstName,
				   deleted.LastName as OldLastName,
				   inserted.LastName as NewLastName,
				   deleted.FirstName + ' ' + deleted.LastName as OldFullName,
				   inserted.FirstName + ' ' + inserted.LastName as NewFullName,
				   deleted.Region as OldRegion,
				   inserted.Region as NewRegion,
				   deleted.Wins as OldWins,
				   inserted.Wins as NewWins,
				   deleted.Losses as OldLosses,
				   inserted.Losses as NewLosses,
				   deleted.RankingScore as OldRankingScore,
				   inserted.RankingScore as NewRankingScore,
				   deleted.CreationDate as OldCreationDate,
				   inserted.CreationDate as NewCreationDate,
				   GetDate() as ChangeDate,
				   Admin.AdminID as AdminID
				   from inserted
				   inner join deleted
				   on inserted.PlayerUnixID = deleted.PlayerUnixID
				   left join Admin
				   on inserted.PlayerUnixID = Admin.PlayerUnixID
				if @@ERROR <> 0 
					begin
					rollback transaction
					raiserror('Update Failed',16,1)
					end
				end
		return