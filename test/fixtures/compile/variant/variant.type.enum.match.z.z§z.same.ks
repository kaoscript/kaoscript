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
		Clubs, Spades {
			names: String[]
		}
	}
	rank: Number
}

func foobar(card: Card) {
	match card {
		.Blacks {
			for var name in card.names {
				echo(`\(name)`)
			}
		}
	}
}