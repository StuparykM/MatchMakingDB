﻿Create Table [dbo].[Media]
(
	ID int identity(1, 1) not null
		Constraint PK_Media Primary Key Clustered,
	PlayerUnixID int not null
		Constraint FK_Media_Player Foreign Key
			References [dbo].[Player](PlayerUnixID),
	"Url" varchar(2048) not null
		Constraint CK_Media_Url Check (Trim("Url") != '' and "Url" like Trim("Url"))
)
GO

Create Nonclustered Index IX_Media_PlayerUnixID
	On [dbo].[Media](PlayerUnixID)
GO

create trigger TR_Media_PreventPKUpdate
	on "Media"
	For update
	As
		Begin
			if @@ROWCOUNT > 0 and (Update(ID))
					Begin
						rollback transaction
							raiserror('Cannot change or update Media ID',16,1)
					End
				End
	Return
GO

create trigger TR_MediaChangeLog_Update
on Media
for update
as
	begin
		if @@ROWCOUNT > 0 and update("Url")
		insert into MediaChangeLog(MediaID, PlayerUnixID, NewUrl, OldUrl, ChangeDate, "Admin")
		select deleted.ID as MediaID,
			   deleted.PlayerUnixID,
			   deleted."Url" as OldUrl,
			   inserted."Url" as NewUrl,
			   GetDate() as ChangeDate,
			   Player.PlayerUnixID as "Admin"
			   from deleted
			   inner join inserted
			   on deleted.ID = inserted.ID
			   left join Player
			   on deleted.PlayerUnixID = Player.PlayerUnixID
			   where Player."Admin" = 1
			if @@ERROR <> 0 
				begin
					rollback transaction
					raiserror('Update Failed',16,1)
				end
			end
		return
	GO
		
	