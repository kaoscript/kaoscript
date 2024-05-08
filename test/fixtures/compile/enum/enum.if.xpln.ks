enum CardSuit<String> {
	Clubs
	Diamonds
	Hearts
	Spades
}

func foobar(test) {
	var card = if test() set CardSuit.Diamonds else CardSuit.Hearts
}