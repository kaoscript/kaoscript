extern console

enum CardSuit<String> {
	Clubs		= 'clb'
	Diamonds	= 'dmd'
	Hearts		= 'hrt'
	Spades		= 'spd'
}

let card = CardSuit::Clubs

console.log(card)