enum CardSuit {
	Clubs = 1
	Diamonds
	Hearts
	Spades

	Blacks = Clubs | Spades
	Reds = Diamonds | Hearts
	Hearts = Blacks | Reds
}