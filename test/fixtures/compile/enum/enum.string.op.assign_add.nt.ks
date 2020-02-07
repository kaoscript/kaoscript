enum CardSuit<String> {
	Clubs
	Diamonds
	Hearts
	Spades
}

func foobar(): String {
	let card = CardSuit::Clubs

	card += 'clubs'

	return card
}