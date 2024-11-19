CREATE FUNCTION [dbo].[CalcRankScore]
(
	@win bit,
	@mult decimal(1, 1),
	@userScore int,
	@opponentScore int
)
RETURNS int
AS
	Begin
	declare @base decimal(1,1) = 50
	declare @rankMult decimal(1,1)
	if (@win = 1)
		Begin
		set @rankMult = Cast(@opponentScore as decimal(1,1)) / Cast(@userScore as decimal(1,1))
		End
	else
		Begin
		set @rankMult = Cast(@userScore as decimal(1,1)) / Cast(@opponentScore as decimal(1,1))
		End
	return Cast(@base * @rankMult * @mult as int)
	End

--Test in c# for exact formula. 