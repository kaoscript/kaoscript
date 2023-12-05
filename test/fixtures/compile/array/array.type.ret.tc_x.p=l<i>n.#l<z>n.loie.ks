type Card = {
    suit: Number
}

func foobar(suits: Number[]?): Card[]? {
	return ?suits ? [{ suit } for var suit in suits] : null
}
