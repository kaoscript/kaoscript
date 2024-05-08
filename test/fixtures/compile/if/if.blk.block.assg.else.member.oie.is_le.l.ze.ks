type Card = {
	kind: Number
}

func foobar(cards: Number[] | Card): { values: Card[] | Card } {
	var result = {
		kind: 0
	}

	if cards is Array {
		result.values = []
	}
	else {
		result.values = cards
	}

	return result
}