enum CardSuit<String> {
	Clubs
	Diamonds
	Hearts
	Spades
}

func foobar(test) {
	var card = test() ? CardSuit.Diamonds : CardSuit.Hearts
}