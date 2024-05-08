require expect: func

enum CardSuit {
	Clubs
	Diamonds
	Hearts
	Spades
}

expect(CardSuit is Enum).to.equal(true)

var suit = CardSuit.Clubs

expect((() => suit)() is CardSuit).to.equal(true)
expect(Type.typeOf(CardSuit)).to.equal('enum')
expect(Type.typeOf(suit)).to.equal('enum-member')

expect(`>>> \(suit)`).to.equal('>>> 0')
expect(`\(suit)`).to.equal('0')

extern JSON

expect(JSON.stringify({
	id: suit
})).to.equal('{"id":0}')

expect(JSON.stringify({
	id: suit.value
})).to.equal('{"id":0}')

func foobar(x: Enum) => 'enum'
func foobar(x: CardSuit) => 'enum-member'
func foobar(x: Number) => 'number'
func foobar(x: Object) => 'object'
func foobar(x: String) => 'string'
func foobar(x) => 'any'

expect(foobar(CardSuit)).to.equal('enum')
expect(foobar(CardSuit.Clubs)).to.equal('enum-member')
expect(foobar(CardSuit.Clubs.value)).to.equal('number')
expect(foobar(0)).to.equal('number')
expect(foobar({})).to.equal('object')
expect(foobar('foo')).to.equal('string')
expect(foobar([])).to.equal('any')

func testIf(x: CardSuit, y: Number, z) {
	var results = []

	if x == CardSuit.Clubs {
		results.push('c')
	}
	else {
		results.push(null)
	}
	if CardSuit(y) == CardSuit.Clubs {
		results.push('c')
	}
	else {
		results.push(null)
	}
	if CardSuit(z) == CardSuit.Clubs {
		results.push('c')
	}
	else {
		results.push(null)
	}

	results.push(if x == CardSuit.Clubs set 'c' else null)
	results.push(if CardSuit(y) == CardSuit.Clubs set 'c' else null)
	results.push(if CardSuit(z) == CardSuit.Clubs set 'c' else null)

	return results
}

expect(testIf(CardSuit.Clubs, CardSuit.Clubs.value, CardSuit.Clubs)).to.eql(['c', 'c', 'c', 'c', 'c', 'c'])
expect(testIf(CardSuit.Diamonds, CardSuit.Clubs.value, CardSuit.Clubs.value)).to.eql([null, 'c', 'c', null, 'c', 'c'])

func testMatch(x: CardSuit, y: Number, z) {
	var results = []

	match x {
		CardSuit.Clubs		=> results.push('c')
		CardSuit.Diamonds	=> results.push('d')
		else				=> results.push(null)
	}

	match CardSuit(y) {
		CardSuit.Clubs		=> results.push('c')
		CardSuit.Diamonds	=> results.push('d')
		else				=> results.push(null)
	}

	match CardSuit(z) {
		CardSuit.Clubs		=> results.push('c')
		CardSuit.Diamonds	=> results.push('d')
		else				=> results.push(null)
	}

	return results
}

expect(testMatch(CardSuit.Clubs, CardSuit.Clubs.value, CardSuit.Clubs)).to.eql(['c', 'c', 'c'])
expect(testMatch(CardSuit.Diamonds, CardSuit.Clubs.value, CardSuit.Clubs.value)).to.eql(['d', 'c', 'c'])