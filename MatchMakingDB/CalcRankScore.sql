Create Function [dbo].[CalcRankScore]
(
	@win bit,
	@mult decimal(1, 1),
	@userScore int,
	@opponentScore int
)
Returns int
AS
	Begin
		Declare @base decimal(1,1) = 50
		Declare @rankMult decimal(1,1)
		Declare @minRank int = 1000
		If (@win = 1)
			Begin
				Set @rankMult = Cast(Max(@opponentScore, @minRank) as decimal(1, 1)) / Cast(Max(@userScore, @minRank) as decimal(1, 1))
			End
		Else
			Begin
				Set @rankMult = Cast(Max(@userScore, @minRank) as decimal(1, 1)) / Cast(Max(@opponentScore, @minRank) as decimal(1, 1)) * -1.0
			End
		Return Cast(@base * @rankMult * @mult as int)
	End