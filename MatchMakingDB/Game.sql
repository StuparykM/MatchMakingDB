create table Game
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
	For insert, update
	As
		Begin
			if @@ROWCOUNT > 0 and (Update(GameID))
				Begin
					if exists (
						select * 
						from "Game"
						where Game.GameID = inserted.GameID
					)
					Begin
						rollback transaction
							raiserror('Cannot change or update Game ID',16,1)
					End
				End
		End
	Return
GO