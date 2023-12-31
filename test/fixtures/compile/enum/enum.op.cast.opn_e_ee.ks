enum CardSuit {
	Clubs
	Diamonds
	Hearts
	Spades
}

func foobar(data: CardSuit): CardSuit? {
	return data:>?(CardSuit)
}