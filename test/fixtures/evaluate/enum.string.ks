require expect: func

enum CardSuit<String> {
	Clubs
	Diamonds
	Hearts
	Spades
}

expect(CardSuit is Enum).to.equal(true)

var suit = (() => CardSuit.Clubs)()

expect(suit is CardSuit).to.equal(true)
expect(Type.typeOf(suit)).to.equal('enum-member')

expect(`>>> \(suit)`).to.equal('>>> clubs')
expect(`\(suit)`).to.equal('clubs')

extern JSON

expect(JSON.stringify({
	id: suit
})).to.equal('{"id":"clubs"}')

expect(JSON.stringify({
	id: suit.value
})).to.equal('{"id":"clubs"}')

func foobar(x: Enum) => 'enum'
func foobar(x: CardSuit) => 'enum-member'
func foobar(x: Number) => 'number'
func foobar(x: Object) => 'dictionary'
func foobar(x: String) => 'string'
func foobar(x) => 'any'

expect(foobar(CardSuit)).to.equal('enum')
expect(foobar(CardSuit.Clubs)).to.equal('enum-member')
expect(foobar(CardSuit.Clubs.value)).to.equal('string')
expect(foobar(0)).to.equal('number')
expect(foobar({})).to.equal('dictionary')
expect(foobar('foo')).to.equal('string')

func testIf(x: CardSuit, y: String, z) {
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

	results.push(x == CardSuit.Clubs ? 'c' : null)
	results.push(CardSuit(y) == CardSuit.Clubs ? 'c' : null)
	results.push(CardSuit(z) == CardSuit.Clubs ? 'c' : null)

	return results
}

expect(testIf(CardSuit.Clubs, CardSuit.Clubs.value, CardSuit.Clubs)).to.eql(['c', 'c', 'c', 'c', 'c', 'c'])
expect(testIf(CardSuit.Diamonds, CardSuit.Clubs.value, CardSuit.Clubs.value)).to.eql([null, 'c', 'c', null, 'c', 'c'])

func testMatch(x: CardSuit, y: String, z) {
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