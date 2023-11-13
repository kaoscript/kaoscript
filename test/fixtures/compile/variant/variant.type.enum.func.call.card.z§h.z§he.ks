enum CardSuit {
	Clubs = 1
	Diamonds
	Hearts
	Spades
}

type Card = {
    variant suit: CardSuit
	rank: Number
}

func foobar(value: Card(Hearts)) {
}

foobar({ suit: CardSuit.Hearts, rank: 1 })