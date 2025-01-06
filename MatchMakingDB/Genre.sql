create table Genre
(
	GenreID int identity(1, 1) not null
		Constraint PK_Genre Primary Key Clustered,
	"Description" varchar(50) not null
		Constraint CK_Genre_Description Check (Trim("Description") != '' and "Description" like Trim("Description"))
)
GO

create trigger TR_Genre_PreventPKUpdate
	on "Genre"
	For insert, update
	As
		Begin
			if @@ROWCOUNT > 0 and (Update(GenreID))
				Begin
					if exists (
						select * 
						from "Genre"
						where Genre.GenreID = inserted.GenreID
					)
					Begin
						rollback transaction
							raiserror('Cannot change or update Genre ID',16,1)
					End
				End
		End
	Return
GO