CREATE TABLE [dbo].[Admin]
(
	AdminID int identity(1, 1) not null
		Constraint PK_Admin Primary Key Clustered,
	PlayerUnixID int not null
		Constraint FK_Admin_Player Foreign Key
			References [dbo].[Player](PlayerUnixID),
	CreationDate DateTime not null
		Constraint DF_Admin_CreationDate Default GetDate()
		Constraint CK_Admin_CreationDate Check (CreationDate <= GetDate())
)
GO

Create Nonclustered Index IX_Admin_PlayerUnixID
	On [dbo].[Admin](PlayerUnixID)
GO

create trigger TR_Admin_PreventPKUpdate
	on "Admin"
	For update
	As
		Begin
			if @@ROWCOUNT > 0 and (Update(AdminID))
					Begin
						rollback transaction
							raiserror('Cannot change or update Admin ID',16,1)
					End
			End
	Return
GO

create trigger TR_AdminChangeLog_AdminCheck
on "Admin"
for update
as
begin
	DECLARE @PlayerUnixID int;
	set @PlayerUnixID = Admin.PlayerUnixID;
	if update(CreationDate)
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

create procedure Admin_InsertData
(@PlayerUnixID int = null, @CreationDate datetime = null)
AS
	BEGIN TRY
		BEGIN TRANSACTION
		IF @PlayerUnixID IS NULL
			BEGIN
				RAISERROR('Player Unix ID cannot be null',16,1)
				ROLLBACK TRANSACTION
				RETURN
			END
		INSERT INTO "Admin" (PlayerUnixID, CreationDate)
		VALUES (@PlayerUnixID, @CreationDate)
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
