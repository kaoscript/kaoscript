type Card = {
    suit: Number
}

func foobar(suits: Number[]?): Card[] | Null {
	if suits is Array {
		return [{ suit } for var suit in suits]
	}

	return null
}
