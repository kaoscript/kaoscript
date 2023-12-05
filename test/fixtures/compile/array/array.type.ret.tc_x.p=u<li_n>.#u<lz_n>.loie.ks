type Card = {
    suit: Number
}

func foobar(suits: Number[] | Null): Card[] | Null {
	return ?suits ? [{ suit } for var suit in suits] : null
}
