﻿CREATE TABLE [dbo].[GenreChangeLog]
(
	ID INT identity(1,1) NOT NULL 
		constraint PK_GenreChangeLog PRIMARY KEY clustered,
	GenreID int null
		constraint FK_GenreChangeLog_GenreID references Genre(GenreID),
	"Description" varchar(50) null
		Constraint CK_GenreChangeLog_Description Check ("Description" like Trim("Description")),
	ChangeDate datetime not null
		constraint CK_GenreChangeLog_ChangeDate check (ChangeDate <= GETDATE()),
	"Admin" int
		constraint FK_GenreChangeLog_PlayerAdmin REFERENCES Player(UnixID) not null
)
