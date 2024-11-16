Create Function [dbo].[IsValidUrl] (@url varchar(2048))
Returns bit As
Begin
	-- Remove protocol and subdomain (Add more as needed)
	Set @url = Replace(@url, 'https://', '')
	Set @url = Replace(@url, 'http://', '')
	Set @url = Replace(@url, 'www.', '')

	-- Regex for url validation: ^[a-zA-Z0-9@:%\._\+~#=]{2,253}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_\+\.~#?&\/=]*)$
	-- Needs to be converted to use SQL wildcards, which is unfortunately much more limited.
	-- Whatever interfaces with this database will need to use a much stronger validation function.
	Declare @regex varchar(255) = '__%.__%'
	
	-- Checks that the url is trimmed and matches our "regex"
	If (@url like Trim(@url) and @url like @regex)
		Begin
			Return 1
		End
	Return 0
End