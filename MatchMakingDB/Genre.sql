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
			insert into GenreChangeLog(GenreID, OldDescription, NewDescription, ChangeDate, AdminID)
			select deleted.GenreID,
				   deleted."Description" as OldDescription,
				   inserted."Description" as NewDescription,
				   GetDate() as ChangeDate,
				   (select AdminID from "Admin" where AdminID = USER_ID()) as AdminID
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

create procedure Genre_InsertData
(@Description varchar(50) = null)
AS
	BEGIN TRY
	BEGIN TRANSACTION
		IF @Description IS NULL
			BEGIN
				RAISERROR('Genre description cannot be null',16,1)
				ROLLBACK TRANSACTION
				RETURN
			END
		INSERT INTO Genre ("Description")
		VALUES (@Description)
			COMMIT TRANSACTION
			END TRY
				BEGIN CATCH
					IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION
						DECLARE @ErrorMessage NVARCHAR(4000), @ErrorSeverity INT, @ErrorState INT, @ErrorLine INT
						SELECT @ErrorMessage = ERROR_MESSAGE(), @ErrorSeverity = ERROR_SEVERITY(), @ErrorState = ERROR_STATE(), @ErrorLine = ERROR_LINE()
						RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState, @ErrorLine)
		END CATCH
GO