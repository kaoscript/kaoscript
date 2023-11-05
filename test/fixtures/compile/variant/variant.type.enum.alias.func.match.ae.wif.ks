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

func greeting(card): String {
	return match card {
        is Card.Blacks => "black"
        is Card.Reds => "red"
	}
}