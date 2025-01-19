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
	For update
	As
		Begin
			if @@ROWCOUNT > 0 and (Update(GenreID))
					Begin
						rollback transaction
							raiserror('Cannot change or update Genre ID',16,1)
					End
				End
	Return
GO

create trigger TR_GenreChangeLog_Update
on Genre
for update
as 
begin
	if @@ROWCOUNT > 0 and update(Description)
		begin
			insert into GenreChangeLog(GenreID, OldDescription, NewDescription, ChangeDate, "Admin")
			select deleted.GenreID,
				   deleted."Description" as OldDescription,
				   inserted."Description" as NewDescription,
				   GetDate() as ChangeDate
				   --inserted."Admin"
				   from deleted
				   inner join inserted
				   on deleted.GenreID = inserted.GenreID
				if @@ERROR <> 0 
					begin
						rollback transaction
						raiserror ('Update Failed', 16,1)
					end
				end
			return
		end
	GO