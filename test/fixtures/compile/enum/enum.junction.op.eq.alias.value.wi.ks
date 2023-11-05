enum CardSuit {
	Clubs = 1
	Diamonds
	Hearts
	Spades

	Blacks = Clubs | Spades
	Reds = Diamonds | Hearts

	C = Clubs
}

func foobar(suit: CardSuit) {
	if suit == .C {
	}
}