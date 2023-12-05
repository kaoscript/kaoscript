type Card = {
    suit: Number
}

func foobar(suits: Number[] | Null): Card[]? {
	if suits is Array {
		return [{ suit } for var suit in suits]
	}

	return null
}
