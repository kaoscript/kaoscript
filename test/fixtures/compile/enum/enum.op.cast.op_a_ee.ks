enum CardSuit {
	Clubs
	Diamonds
	Hearts
	Spades
}

func foobar(data): CardSuit {
	return data:&(CardSuit)
}