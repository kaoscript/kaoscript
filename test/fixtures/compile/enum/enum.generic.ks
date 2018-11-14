extern console: {
	log(...args)
}

enum CardSuit<string> {
	Clubs
	Diamonds
	Hearts
	Spades
}

let card = CardSuit::Clubs

console.log(card)