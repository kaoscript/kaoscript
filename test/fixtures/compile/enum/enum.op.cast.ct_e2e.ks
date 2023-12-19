enum CardSuit {
	Clubs
	Diamonds
	Hearts
	Spades
}

enum PersonKind {
    Director
    Student
    Teacher
}

func foobar(data: PersonKind): CardSuit? {
	return CardSuit(data)
}