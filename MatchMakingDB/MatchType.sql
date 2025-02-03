create table MatchType
(
	MatchTypeID int identity(1,1) not null
		Constraint PK_MatchType Primary Key Clustered,
	"Type" varchar(50) not null
		Constraint CK_MatchType_Type Check (Trim("Type") != '' and "Type" like Trim("Type")),
	Multiplier decimal(1,1) not null
		Constraint DF_MatchType_Multiplier Default 1.0
		Constraint CK_MatchType_Multiplier Check (Multiplier >= 0)
)
GO

create trigger TR_MatchType_PreventPKUpdate
	on "MatchType"
	For update
	As
		Begin
			if @@ROWCOUNT > 0 and (Update(MatchTypeID))
					Begin
						rollback transaction
							raiserror('Cannot change or update MatchType ID',16,1)
					End
				End
	Return
GO

create trigger TR_MatchTypeChangeLog_Update
on MatchType
for Update
as
	begin
		if update("Type") or update(Multiplier)
			insert into MatchTypeChangeLog(MatchTypeID, OldType, NewType, OldMultiplier, NewMultiplier, ChangeDate, AdminID)
			select deleted.MatchTypeID,
				   deleted."Type" as OldType,
				   inserted."Type" as NewType,
				   deleted.Multiplier as OldMultiplier,
				   inserted.Multiplier as NewMultiplier,
				   GetDate() as ChangeDate,
				   (select PlayerUnixID from Player where IsAdmin = 1 and PlayerUnixID = USER_ID()) as AdminID
				   from deleted
				   inner join inserted
				   on deleted.MatchTypeID = inserted.MatchTypeID 
				if @@ERROR <> 0 
					begin
						rollback transaction
						raiserror ('Update Failed',16,1)
					end
				end
			return
	GO
