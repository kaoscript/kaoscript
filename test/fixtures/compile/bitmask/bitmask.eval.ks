require expect: func

bitmask Foobar {
	foo = 1
	bar
	qux
}

func foobar(x: Foobar) => 'enum'
func foobar(x: Number) => 'number'
func foobar(x: Dictionary) => 'dictionary'

expect(foobar(Foobar::foo)).to.equal('enum')
expect(foobar(Foobar::foo + Foobar::bar)).to.equal('enum')
expect(foobar(0)).to.equal('number')
expect(foobar({})).to.equal('dictionary')

func testIf(x: Foobar, y: Number, z) {
	var results = []

	if x ~~ Foobar::foo {
		results.push('c')
	}
	else {
		results.push(null)
	}
	if y ~~ Foobar::foo {
		results.push('c')
	}
	else {
		results.push(null)
	}
	if z ~~ Foobar::foo {
		results.push('c')
	}
	else {
		results.push(null)
	}

	results.push(x ~~ Foobar::foo ? 'c' : null)
	results.push(y ~~ Foobar::foo ? 'c' : null)
	results.push(z ~~ Foobar::foo ? 'c' : null)

	return results
}

expect(testIf(Foobar::foo + Foobar::bar, Foobar::foo + Foobar::bar, Foobar::foo + Foobar::bar)).to.eql(['c', 'c', 'c', 'c', 'c', 'c'])
expect(testIf(Foobar::bar, Foobar::foo.value || Foobar::bar.value, Foobar::foo.value || Foobar::bar.value)).to.eql([null, 'c', 'c', null, 'c', 'c'])