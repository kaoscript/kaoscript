enum CardSuit<String> {
	Clubs
	Diamonds
	Hearts
	Spades
}

func foobar(): String {
	var dyn card = CardSuit::Clubs

	card += 'clubs'

	return card
}