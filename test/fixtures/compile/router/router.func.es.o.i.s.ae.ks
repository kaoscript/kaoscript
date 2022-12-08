enum CardSuit<String> {
	Clubs
	Diamonds
	Hearts
	Spades
}

func foobar(x: CardSuit) => 'card'
func foobar(x: Object) => 'object'
func foobar(x: Number) => 'number'
func foobar(x: String) => 'string'
func foobar(x) => 'any'