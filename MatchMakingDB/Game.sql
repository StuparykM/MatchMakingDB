﻿create table Game
(
	GameID int identity(1,1)
		constraint PK_Game PRIMARY KEY CLUSTERED not null,
	"Name" varchar(50) not null
		Constraint CK_Game_Name Check (Trim("Name") != '' and "Name" like Trim("Name")),
	GenreID int
		constraint FK_Game_Genre REFERENCES Genre(GenreID) not null,
	"Version" varchar(50)
		constraint DF_Game_Version DEFAULT 1.0 not null
)
GO

create nonclustered index IX_Game_GenreID
	ON Game (GenreID)
GO

create trigger TR_Game_PreventPKUpdate
	on "Game"
	For update
	As
		Begin
			if @@ROWCOUNT > 0 and (Update(GameID))
					Begin
						rollback transaction
							raiserror('Cannot change Game ID',16,1)
					End
				End
	Return
GO

create trigger TR_GameChangeLog_AdminCheck
on Game
for update
as
begin
	DECLARE @PlayerUnixID int;
	set @PlayerUnixID = Admin.PlayerUnixID;
	if update("Name") or update("Version")
	select *
	from Admin
	where PlayerUnixID = USER_ID(@PlayerUnixID)/*this function will need to be updated, USER_ID is depreciating in the future*/ 
if @@ERROR <> 0 
	begin
	rollback transaction
	raiserror('Do not have permissions for update',16,1)
	end
end
GO

create trigger TR_GameChangeLog_Update
on Game
for update
as
begin
	if update("Name") or update("Version")
		begin
		declare @PlayerUnixID int;
		set @PlayerUnixID = Admin.PlayerUnixID
			insert into GameChangeLog (GameID, "NewName", OldName, NewVersion, OldVersion, ChangeDate, AdminID)
			select deleted.GameID,
				   deleted."Name" as OldName,
				   inserted."Name" as "NewName",
				   inserted."Version" as NewVersion,
				   deleted."Version" as OldVersion,
				   GetDate() as ChangeDate,
				   @PlayerUnixID as AdminID
				   from inserted
				   inner join deleted
				   on inserted.GameID = deleted.GameID
				if @@ERROR <> 0
					begin
						rollback transaction
						raiserror ('Update Failed', 16,1)
					end
				end
		return
end
GO