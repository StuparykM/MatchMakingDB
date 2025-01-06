CREATE TABLE [dbo].[MediaChangeLog]
(
	ID int identity(1,1)
		constraint PK_MediaChangeLog primary key clustered not null,
	MediaID int 
		constraint FK_MediaChangeLog_MediaID references Media(ID) not null,
	PlayerUnixID int null
		Constraint FK_MediaChangeLog_Player Foreign Key
			References [dbo].[Player](UnixID),
	"Url" varchar(2048) null
		Constraint CK_MediaChangeLog_Url Check ("Url" like Trim("Url")),
	ChangeDate datetime not null
		constraint CK_MediaChangeLog_ChangeDate check (ChangeDate <= GETDATE()),
	"Admin" int
		constraint FK_MediaChangeLog_PlayerAdmin REFERENCES Player(UnixID) not null
)
GO

Create Nonclustered Index IX_MediaChangeLog_PlayerUnixID
	On [dbo].[MediaChangeLog](PlayerUnixID)
GO

create trigger TR_MediaChangeLog_PreventPKUpdate
	on "MediaChangeLog"
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