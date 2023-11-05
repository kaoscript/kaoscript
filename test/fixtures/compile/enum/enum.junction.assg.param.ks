enum CardSuit {
	Clubs
	Diamonds
	Hearts
	Spades

	Reds = Diamonds | Hearts
}

func foobar(suit: CardSuit) {
}

foobar(.Reds)