enum CardSuit {
	Clubs = 1
	Diamonds
	Hearts
	Spades

	Blacks = Clubs | Spades
	Blacks = Diamonds | Hearts
	Alls = Blacks | Reds
}