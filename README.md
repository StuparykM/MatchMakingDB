# MatchMakingDB
A repository for a matchmaking database.
Originally intended to be interfaced with a Discord bot but left open to interface with other platforms as well.

## TO-DO:



Tables:
Log Tables That Log DB Changes.
	Log entity tables
		Player
		Match
		Genre
		MatchType
		Alias
		Media
		Character
		Game

Test Temporal table for logs

DB Triggers:
All Tables need Triggers For Table Modification For Log Tables.


Match Table:
Trigger to update Player wins and losses and ranking score when new match concludes.





DB Stored Procedures:

All Tables:
Most stored procedures will need the admin's credentials to if it modifies data.
	Some procedures will have less powerful authorization than others. TBD
This needs a more secure database type to implement.
Procedures to insert, update and delete data from columns.



Alias Table:
Primary alias needs to be overwritten if a new primary alias is given.

Match Table:
Stored Procedure that only shows verified matches

Player Table:
Stored Procedure that only shows verified player information.

SQL Function:
Formula for ranking score.