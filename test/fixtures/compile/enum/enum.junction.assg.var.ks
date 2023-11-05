enum CardSuit {
	Clubs
	Diamonds
	Hearts
	Spades

	Reds = Diamonds | Hearts
}

var suit = CardSuit.Reds