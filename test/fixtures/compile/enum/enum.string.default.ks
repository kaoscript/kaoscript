extern console: {
	log(...args)
}

enum CardSuit<string> {
	Clubs
	Diamonds
	Hearts
	Spades
}

var dyn card = CardSuit::Clubs

console.log(card)