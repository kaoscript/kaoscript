enum CardSuit {
	Clubs = 1
	Diamonds
	Hearts
	Spades

	Blacks = Clubs | Spades
	Reds = Diamonds | Hearts
	Alls = Blacks | Reds
}

func foobar(suit: CardSuit) {
	if suit == .Blacks {
	}
}