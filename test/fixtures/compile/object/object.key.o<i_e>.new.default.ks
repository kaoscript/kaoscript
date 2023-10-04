enum CardSuit {
	Clubs
	Diamonds
	Hearts
	Spades
}

var $precedence: Object<Number, CardSuit> = {
	[CardSuit.Clubs]: 0
	[CardSuit.Diamonds]: 0
}