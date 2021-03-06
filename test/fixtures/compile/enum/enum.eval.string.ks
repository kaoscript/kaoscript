require expect: func

enum CardSuit<String> {
	Clubs
	Diamonds
	Hearts
	Spades
}

expect(CardSuit is Enum).to.equal(true)

const x = CardSuit::Clubs

expect(x is CardSuit).to.equal(true)
expect(Type.typeOf(x)).to.equal('enum-member')

expect(`>>> \(x)`).to.equal('>>> clubs')
expect(`\(x)`).to.equal('clubs')

extern JSON

expect(JSON.stringify({
	id: x
})).to.equal('{"id":"clubs"}')

expect(JSON.stringify({
	id: x.value
})).to.equal('{"id":"clubs"}')

func foobar(x: Enum) => 'enum'
func foobar(x: CardSuit) => 'enum-member'
func foobar(x: Number) => 'number'
func foobar(x: Dictionary) => 'dictionary'
func foobar(x: String) => 'string'
func foobar(x) => 'any'

expect(foobar(CardSuit)).to.equal('enum')
expect(foobar(CardSuit::Clubs)).to.equal('enum-member')
expect(foobar(CardSuit::Clubs.value)).to.equal('string')
expect(foobar(0)).to.equal('number')
expect(foobar({})).to.equal('dictionary')
expect(foobar('foo')).to.equal('string')

func testIf(x: CardSuit, y: String, z) {
	const results = []

	if x == CardSuit::Clubs {
		results.push('c')
	}
	else {
		results.push(null)
	}
	if y == CardSuit::Clubs {
		results.push('c')
	}
	else {
		results.push(null)
	}
	if z == CardSuit::Clubs {
		results.push('c')
	}
	else {
		results.push(null)
	}

	results.push(x == CardSuit::Clubs ? 'c' : null)
	results.push(y == CardSuit::Clubs ? 'c' : null)
	results.push(z == CardSuit::Clubs ? 'c' : null)

	return results
}

expect(testIf(CardSuit::Clubs, CardSuit::Clubs, CardSuit::Clubs)).to.eql(['c', 'c', 'c', 'c', 'c', 'c'])
expect(testIf(CardSuit::Diamonds, CardSuit::Clubs.value, CardSuit::Clubs.value)).to.eql([null, 'c', 'c', null, 'c', 'c'])

func testSwitch(x: CardSuit, y: String, z) {
	const results = []

	switch x {
		CardSuit::Clubs		=> results.push('c')
		CardSuit::Diamonds	=> results.push('d')
							=> results.push(null)
	}

	switch y {
		CardSuit::Clubs		=> results.push('c')
		CardSuit::Diamonds	=> results.push('d')
							=> results.push(null)
	}

	switch z {
		CardSuit::Clubs		=> results.push('c')
		CardSuit::Diamonds	=> results.push('d')
							=> results.push(null)
	}

	return results
}

expect(testSwitch(CardSuit::Clubs, CardSuit::Clubs, CardSuit::Clubs)).to.eql(['c', 'c', 'c'])
expect(testSwitch(CardSuit::Diamonds, CardSuit::Clubs.value, CardSuit::Clubs.value)).to.eql(['d', 'c', 'c'])