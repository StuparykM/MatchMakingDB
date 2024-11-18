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