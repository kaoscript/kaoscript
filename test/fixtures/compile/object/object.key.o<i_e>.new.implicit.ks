enum CardSuit {
	Clubs
	Diamonds
	Hearts
	Spades
}

var $precedence: Object<Number, CardSuit> = {
	[.Clubs]: 0
	[.Diamonds]: 0
}