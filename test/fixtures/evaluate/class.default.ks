require expect: func

class CardSuit {
	private {
		@family: String
		@value: Number
	}
	constructor(@family, @value)
}

expect(CardSuit is Class).to.equal(true)

var x = new CardSuit('clubs', 8)

expect(x is CardSuit).to.equal(true)
expect(Type.typeOf(CardSuit)).to.equal('class')
expect(Type.typeOf(x)).to.equal('object')