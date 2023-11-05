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

func greeting(card: Card): String {
	return match card {
        .Blacks => "black"
        .Reds => "red"
	}
}