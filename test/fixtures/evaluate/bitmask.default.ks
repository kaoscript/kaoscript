require expect: func

bitmask Foobar {
	foo = 1
	bar
	qux
}

func foobar(x: Foobar) => 'enum'
func foobar(x: Number) => 'number'
func foobar(x: Object) => 'object'

expect(foobar(Foobar.foo)).to.equal('enum')
expect(foobar(Foobar.foo + Foobar.bar)).to.equal('enum')
expect(foobar(0)).to.equal('number')
expect(foobar({})).to.equal('object')

func testIf(x: Foobar, y: Number, z) {
	var results = []

	if x ~~ Foobar.foo {
		results.push('c')
	}
	else {
		results.push(null)
	}
	if Foobar(y) ~~ Foobar.foo {
		results.push('c')
	}
	else {
		results.push(null)
	}
	if Foobar(z) ~~ Foobar.foo {
		results.push('c')
	}
	else {
		results.push(null)
	}

	results.push(if x ~~ Foobar.foo set 'c' else null)
	results.push(if y ~~ Foobar.foo set 'c' else null)
	results.push(if z ~~ Foobar.foo set 'c' else null)

	return results
}

expect(testIf(Foobar.foo + Foobar.bar, (Foobar.foo + Foobar.bar).value, Foobar.foo + Foobar.bar)).to.eql(['c', 'c', 'c', 'c', 'c', 'c'])
expect(testIf(Foobar.bar, Foobar.foo.value +| Foobar.bar.value, Foobar.foo.value +| Foobar.bar.value)).to.eql([null, 'c', 'c', null, 'c', 'c'])