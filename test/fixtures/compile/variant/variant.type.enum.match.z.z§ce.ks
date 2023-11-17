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
	}
	rank: Number
}

func foobar(card: Card) {
	match card {
		.Clubs {
			for var name in card.names {
				echo(`\(name)`)
			}
		}
		.Spades {
		}
	}
}