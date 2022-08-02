require expect: func

tuple Pair(String, Number)

expect(Pair is Tuple).to.equal(true)
expect(Type.typeOf(Pair)).to.equal('tuple')

var pair = Pair('x', 0.1)

expect(pair is Pair).to.equal(true)
expect(Type.typeOf(pair)).to.equal('tuple-instance')

expect(pair.0).to.equal('x')
expect(pair.1).to.equal(0.1)

func foobar(x: Tuple) => 'tuple'
func foobar(x: Pair) => 'tuple-instance'
func foobar(x: Number) => 'number'
func foobar(x: Dictionary) => 'dictionary'
func foobar(x: String) => 'string'
func foobar(x) => 'any'

expect(foobar(Pair)).to.equal('tuple')
expect(foobar(pair)).to.equal('tuple-instance')
expect(foobar(pair.0)).to.equal('string')
expect(foobar(pair.1)).to.equal('number')
expect(foobar(0)).to.equal('number')
expect(foobar({})).to.equal('dictionary')
expect(foobar('foo')).to.equal('string')
expect(foobar([])).to.equal('any')