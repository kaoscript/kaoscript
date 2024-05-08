type Card = {
    suit: Number
}

func foobar(suits: Number[] | Null): Card[] | Null {
	return if ?suits set [{ suit } for var suit in suits] else null
}
