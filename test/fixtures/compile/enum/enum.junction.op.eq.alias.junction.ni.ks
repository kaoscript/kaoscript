enum CardSuit {
	Clubs = 1
	Diamonds
	Hearts
	Spades

	Blacks = Clubs | Spades
	Reds = Diamonds | Hearts

	C = Clubs
	B = Blacks
	D = Diamonds
	H = Hearts
	R = Reds
	S = Spades
}

func foobar(suit: CardSuit) {
	if suit == CardSuit.B {
	}
}