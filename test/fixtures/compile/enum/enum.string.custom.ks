extern console

enum CardSuit<String> {
	Clubs		= 'clb'
	Diamonds	= 'dmd'
	Hearts		= 'hrt'
	Spades		= 'spd'
}

var dyn card = CardSuit.Clubs

console.log(card)