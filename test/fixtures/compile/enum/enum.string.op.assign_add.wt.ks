enum CardSuit<String> {
	Clubs
	Diamonds
	Hearts
	Spades
}

func foobar(): CardSuit {
	auto card = CardSuit::Clubs

	card += 'clubs'

	return card
}