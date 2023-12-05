type Card = {
	kind: Number
}

func foobar(cards: Number[] | Card): { values: Card[] | Card } {
	var result = {
		kind: 0
	}

	if cards is Array<Number> {
		result.values = [{ kind } for var kind in cards]
	}
	else {
		result.values = cards
	}

	return result
}