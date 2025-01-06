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
	For insert, update
	As
		Begin
			if @@ROWCOUNT > 0 and (Update(MatchTypeID))
				Begin
					if exists (
						select * 
						from "MatchType"
						where MatchType.MatchTypeID = inserted.MatchTypeID
					)
					Begin
						rollback transaction
							raiserror('Cannot change or update MatchType ID',16,1)
					End
				End
		End
	Return
GO