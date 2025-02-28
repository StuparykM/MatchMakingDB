Create Table [dbo].[Alias] (
	AliasID int identity(1, 1) not null
		Constraint PK_Alias Primary Key Clustered,
	PlayerUnixID int not null
		Constraint FK_Alias_Player Foreign Key
			References [dbo].[Player](PlayerUnixID),
	"Name" varchar(50) not null
		Constraint CK_Alias_Name Check (Trim("Name") != '' and "Name" like Trim("Name")),
	"Primary" bit not null
		Constraint DF_Alias_Primary Default 0
)
GO

Create Nonclustered Index IX_Alias_PlayerUnixID
	On [dbo].[Alias](PlayerUnixID)
GO

Create Trigger TR_Max_One_Primary_Alias
	On [dbo].[Alias]
	For Insert, Update, Delete
	As
		Begin
			If @@ROWCOUNT > 0 and Update("Primary")
				Begin
					If (
						Select Count(*)
							From [dbo].[Alias]
							Where [dbo].[Alias]."Primary" = 1
					) > 1
						Begin
							Rollback Transaction
							RaisError('A player cannot have more than 1 primary alias.', 16, 1)
						End
				End
		End
	Return
GO

create trigger TR_Alias_PreventPKUpdate
	on "Alias"
	For update
	As
		Begin
			if @@ROWCOUNT > 0 and (Update(AliasID))
					Begin
						rollback transaction
							raiserror('Cannot change or update Alias ID of a player',16,1)
					End
				End
	Return
GO

create trigger TR_AliasChangeLog_AdminCheck
on Alias
for update
as
begin
	DECLARE @PlayerUnixID int;
	set @PlayerUnixID = Admin.PlayerUnixID;
	if update("Name") or update("Primary")
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



create trigger TR_AliashChangeLog_Update
on Alias
for update
as
begin
	if update("Name") or update("Primary")
	begin
	declare @PlayerUnixID int;
	set @PlayerUnixID = Admin.PlayerUnixID
	insert into AliasChangeLog(AliasID, OldName, "NewName", "Primary", ChangeDate, AdminID)
	select deleted.AliasID,
		   deleted."Name" as OldName,
		   inserted."Name" as "NewName",
		   inserted."Primary",
		   GetDate() as ChangeDate,
		   @PlayerUnixID as AdminID
		   from inserted
		   inner join deleted
		   on inserted.AliasID = deleted.AliasID
		if @@ERROR <> 0 
			begin
			rollback transaction
			raiserror ('Update failed', 16,1)
			end
		end
	return
end
GO

create procedure Alias_InsertData
(@PlayerUnixID int = null, @Name varchar(50) = null, @Primary bit = null)
AS
	BEGIN TRY
	BEGIN TRANSACTION
		IF @PlayerUnixID IS NULL
			BEGIN
				RAISERROR('Player Unix ID cannot be null',16,1)
				ROLLBACK TRANSACTION
				RETURN
			END
		IF @Name IS NULL
			BEGIN
				RAISERROR('Alias Name cannot be null',16,1)
				ROLLBACK TRANSACTION
				RETURN
			END
		IF @Primary IS NULL
			BEGIN
				RAISERROR('Primary Alias cannot be null',16,1)
				ROLLBACK TRANSACTION
				RETURN
			END
		INSERT INTO Alias (PlayerUnixID, "Name", "Primary")
		VALUES (@PlayerUnixID, @Name, @Primary)
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
