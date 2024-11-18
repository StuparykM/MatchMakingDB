create table Genre
(
	GenreID int identity(1, 1) not null
		Constraint PK_Genre Primary Key Clustered,
	"Description" varchar(50) not null
		Constraint CK_Genre_Description Check (Trim("Description") != '' and "Description" like Trim("Description"))
)
