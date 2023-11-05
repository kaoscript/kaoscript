require expect: func

struct Point {
    x: Number
    y: Number
}

expect(Point is Struct).to.equal(true)
expect(Type.typeOf(Point)).to.equal('struct')

var point = Point.new(0.3, 0.4)

expect((() => point)() is Point).to.equal(true)
expect(Type.typeOf(point)).to.equal('struct-instance')

expect(point.x).to.equal(0.3)
expect(point.y).to.equal(0.4)

func foobar(x: Struct) => 'struct'
func foobar(x: Point) => 'struct-instance'
func foobar(x: Number) => 'number'
func foobar(x: Object) => 'object'
func foobar(x: String) => 'string'
func foobar(x) => 'any'

expect(foobar(Point)).to.equal('struct')
expect(foobar(point)).to.equal('struct-instance')
expect(foobar(point.x)).to.equal('number')
expect(foobar(point.y)).to.equal('number')
expect(foobar(0)).to.equal('number')
expect(foobar({})).to.equal('object')
expect(foobar('foo')).to.equal('string')
expect(foobar([])).to.equal('any')