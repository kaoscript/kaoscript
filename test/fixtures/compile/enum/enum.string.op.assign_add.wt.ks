enum CardSuit<String> {
	Clubs
	Diamonds
	Hearts
	Spades
}

func foobar(): CardSuit {
	var mut card = CardSuit::Clubs

	card += 'clubs'

	return card
}