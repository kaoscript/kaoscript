enum CardSuit {
	Clubs = 1
	Diamonds
	Hearts
	Spades
}

func foobar(card) {
	unless card.suit == CardSuit.Diamonds | CardSuit.Hearts | CardSuit.Spades {
	}
}