Create Function [dbo].[IsValidUrl] (@url varchar(2048))
Returns bit As
Begin
	-- Regex For Url: ^[(http(s)?:\/\/)?(www\.)?a-zA-Z0-9@:%\._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+\.~#?&\/=]*)$

	-- To be replace with real logic
	Return 1
End