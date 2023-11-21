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
			name: String
		}
	}
	rank: Number
}

func foobar(card: Card(Blacks)) {
	if ?card.name {
		echo(`\(card.name)`)
	}
}