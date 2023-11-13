enum CardSuit {
	Clubs = 1
	Diamonds
	Hearts
	Spades

	Blacks = Clubs | Spades
	Reds = Diamonds | Hearts
}

type Card = {
    variant suit: CardSuit
	rank: Number
}

func foobar(value: Card(Reds)) {
}

foobar({ suit: CardSuit.Hearts, rank: 1 })