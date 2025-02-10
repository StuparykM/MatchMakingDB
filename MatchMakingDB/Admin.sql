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