enum CardSuit {
	Clubs = 1
	Diamonds
	Hearts
	Spades

	Blacks = Clubs | Spades
	Reds = Diamonds | Hearts
}

type Card = {
    variant suit: CardSuit {
		Clubs {
			names: String[]
		}
		Spades {
			values: String[]
		}
	}
	rank: Number
}