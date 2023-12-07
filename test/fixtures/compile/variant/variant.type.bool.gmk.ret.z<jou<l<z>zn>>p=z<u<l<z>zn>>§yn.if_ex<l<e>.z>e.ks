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

type Event<T> = {
	variant ok: Boolean {
		false, N {
		}
		true, Y {
			value: T
			line: Number
			column: Number
		}
	}
}

func foobar(cards: Event<CardSuit[] | Card | Null>(Y)?, { line, column }: Position): Result {
	var result = {
		line
		column
	}

	if ?cards {
		if cards.value is Array {
			result.values = [suit for var suit in cards.value]
		}
		else {
			result.values = cards.value
		}
	}

	return result
}