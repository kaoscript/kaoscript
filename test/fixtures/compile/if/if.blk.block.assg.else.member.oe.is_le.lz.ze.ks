type Card = {
	kind: Number
}

func foobar(cards: Number[] | Card): { values: Card[] | Card } {
	var result = {}

	if cards is Array {
		result.values = [{ kind } for var kind in cards]
	}
	else {
		result.values = cards
	}

	return result
}