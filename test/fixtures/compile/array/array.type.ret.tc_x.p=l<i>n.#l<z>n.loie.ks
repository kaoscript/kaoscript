type Card = {
    suit: Number
}

func foobar(suits: Number[]?): Card[]? {
	return if ?suits set [{ suit } for var suit in suits] else null
}
