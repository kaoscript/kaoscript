require expect: func

struct Pair(String, Number)

expect(Pair is Struct).to.equal(true)
expect(Type.typeOf(Pair)).to.equal('struct')

const pair = new Pair('x', 0.1)

expect(pair is Pair).to.equal(true)
expect(Type.typeOf(pair)).to.equal('struct-instance')

expect(pair.0).to.equal('x')
expect(pair.1).to.equal(0.1)

func foobar(x: Struct) => 'struct'
func foobar(x: Pair) => 'struct-instance'
func foobar(x: Number) => 'number'
func foobar(x: Dictionary) => 'dictionary'
func foobar(x: String) => 'string'
func foobar(x) => 'any'

expect(foobar(Pair)).to.equal('struct')
expect(foobar(pair)).to.equal('struct-instance')
expect(foobar(pair.0)).to.equal('string')
expect(foobar(pair.1)).to.equal('number')
expect(foobar(0)).to.equal('number')
expect(foobar({})).to.equal('dictionary')
expect(foobar('foo')).to.equal('string')
expect(foobar([])).to.equal('any')