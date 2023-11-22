type Card = {
	suit: String
	rank: Number
}

func foobar(cards: { value: Card }[]?): { cards: Card[] } {
	return {
		cards: if ?cards {
				set [card.value for var card in cards]
			}
			else {
				set []
			}
	}
}