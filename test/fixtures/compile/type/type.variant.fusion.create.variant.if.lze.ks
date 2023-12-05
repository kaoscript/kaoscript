type Position = {
	line: Number
	column: Number
}

enum CardSuit {
	Clubs = 1
	Diamonds
	Hearts
	Spades
}

type Card = {
    variant suit: CardSuit {
	}
}

type Result = Position & {
	values: Card[] |  Card | Null
}

func foobar(cards: CardSuit[] | Card | Null, { line, column }: Position): Result {
	var result = {
		line
		column
	}

	if ?cards {
		if cards is CardSuit[] {
			result.values = [{ suit } for var suit in cards]
		}
		else {
			result.values = cards
		}
	}

	return result
}
