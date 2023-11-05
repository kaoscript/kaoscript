enum CardSuit {
	Clubs = 1
	Diamonds
	Hearts
	Spades

	Blacks = Clubs | Spades
	Reds = Diamonds | Hearts
	Alls = Blacks | Reds
}

func foobar() => CardSuit.Clubs

if foobar() == CardSuit.Blacks {
}
