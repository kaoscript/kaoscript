enum CardSuit {
	Clubs = 1
	Diamonds
	Hearts
	Spades

	Reds = Diamonds | Hearts
}

func foobar(card) {
	match card.suit {
		CardSuit.Reds {
		}
	}
}