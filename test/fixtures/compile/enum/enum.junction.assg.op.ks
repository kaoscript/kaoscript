enum CardSuit {
	Clubs
	Diamonds
	Hearts
	Spades

	Reds = Diamonds | Hearts
}

var mut suit = null

suit = CardSuit.Reds