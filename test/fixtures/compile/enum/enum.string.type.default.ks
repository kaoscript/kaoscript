extern console

enum CardSuit<string> {
	Clubs
	Diamonds
	Hearts
	Spades
}

func foobar(x: String) {
}

foobar(CardSuit.Hearts)

func quxbaz(x: CardSuit, y: CardSuit): String {
	return x + y
}