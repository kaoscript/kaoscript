enum Weekday {
    MONDAY = 1
    TUESDAY
    WEDNESDAY
    THURSDAY
    FRIDAY
    SATURDAY
    SUNDAY
}

enum CardSuit {
	Clubs = 1
	Diamonds
	Hearts
	Spades
}

enum Color {
	Red
	Green
	Blue
}

type Card = {
	color: Color
	suit: CardSuit
	value: Number
}

func foobar(card: Card) {
}

export *