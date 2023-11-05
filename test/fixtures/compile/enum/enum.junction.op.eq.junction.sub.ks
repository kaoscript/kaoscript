enum CardSuit {
	Clubs = 1
	Diamonds
	Hearts
	Spades

	Blacks = Clubs | Spades
	Reds = Diamonds | Hearts
	NoHearts = Blacks | Diamonds
}

func foobar(suit: CardSuit) {
	if suit == .NoHearts {
	}
}