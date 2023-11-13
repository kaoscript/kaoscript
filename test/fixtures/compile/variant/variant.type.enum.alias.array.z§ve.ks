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

func getBlack(): Card(Blacks) => { suit: .Spades, rank: 1 }
func getClub(): Card(Clubs) => { suit: .Clubs, rank: 1 }

var cards: Card(Blacks)[] = [
	getClub()
]