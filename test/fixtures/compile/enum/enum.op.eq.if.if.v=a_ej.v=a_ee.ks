enum CardSuit {
	Clubs = 1
	Diamonds
	Hearts
	Spades

	Reds = Diamonds | Hearts
}

func foobar(card) {
	if card.suit == CardSuit.Reds {
		if card.suit == CardSuit.Hearts {
		}
		else {
		}
	}
}