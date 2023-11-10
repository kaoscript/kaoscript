enum CardSuit {
	Clubs
	Diamonds
	Hearts
	Spades
}

class Foobar {
	private {
		@card: CardSuit?
	}
	foobar() {
		if @card == CardSuit.Diamonds {
			@quxbaz()

			if @card == CardSuit.Clubs {
			}
		}
	}
	quxbaz() {
		@card = null
	}
}