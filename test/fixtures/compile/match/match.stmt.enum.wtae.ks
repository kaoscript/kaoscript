enum CardSuit<String> {
	Clubs
	Diamonds
	Hearts
	Spades
}

func foobar(card) {
	match card {
		CardSuit::Clubs		=> echo('clubs')
		CardSuit::Diamonds	=> echo('diamonds')
		else				=> echo('hearts or spades')
	}
}