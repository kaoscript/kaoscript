enum CardSuit {
	Clubs = 1
	Diamonds
	Hearts
	Spades

	Blacks = Clubs | Spades
	Reds = Diamonds | Hearts
	NoHearts = Blacks | Diamonds

	C = Clubs
	B = Blacks
	D = Diamonds
	H = Hearts
	R = Reds
	S = Spades
}

export CardSuit