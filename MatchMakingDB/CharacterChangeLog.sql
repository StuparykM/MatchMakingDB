Create Table [dbo].[CharacterChangeLog] (
	ID int identity(1,1) not null
		Constraint PK_CharacterChangeLog Primary Key Clustered,
	CharacterID int not null
		Constraint FK_CharacterChangeLog_Character Foreign Key
			References "Character"(CharacterID),
	CharacterName varchar(50) null,
	ChangeDate DateTime not null
		Constraint CK_CharacterChangeLog_ChangeDate Check (ChangeDate <= getdate()),
	"Admin" int not null
		Constraint FK_CharacterChangeLog_PlayerAdmin Foreign Key
			References Player(UnixID)
)
GO

Create Nonclustered Index IX_CharacterChangeLog_CharacterID
	On CharacterChangeLog(CharacterID)
GO

create trigger TR_CharacterChangeLog_PreventPKUpdate
	on "CharacterChangeLog"
	For update
	As
		Begin
			if @@ROWCOUNT > 0 and (Update(ID))
					Begin
						rollback transaction
							raiserror('Cannot change Log ID',16,1)
					End
				End
	Return
GO

create trigger TR_CharacterChangeLog_Update
on CharacterChangeLog
for insert, update
as
begin

    if @@ROWCOUNT > 0 and update(CharacterID)
    begin
        begin try
            merge into CharacterChangeLog as target
            using (select inserted.CharacterID, c."CharacterName"
                   from "Character" as c
				   inner join inserted
				   on c.CharacterID = inserted.CharacterID) AS Source
            on target.CharacterID = Source.CharacterID
            when matched then
                update set
                    target."CharacterName" = Source."CharacterName",
                    target.ChangeDate = GetDate(),
                    target."Admin" = "Admin"
            when not matched by target then
                insert (CharacterID, "CharacterName", ChangeDate, "Admin")
                values (Source.CharacterID, Source."CharacterName");
        end try
        begin catch
            ROLLBACK TRANSACTION;
            RAISERROR ('Insert or Update Failed', 16, 1);
        end catch
    end
end;
GO