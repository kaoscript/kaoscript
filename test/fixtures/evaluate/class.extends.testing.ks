require expect: func

class Point {
    x: Number
    y: Number
	constructor(@x, @y)
}

expect(Point is Class).to.equal(true)
expect(Type.typeOf(Point)).to.equal('class')

class Point3D extends Point {
	z: Number
	constructor(@x, @y, @z) {
		super(x, y)
	}
}

expect(Point3D is Class).to.equal(true)
expect(Type.typeOf(Point3D)).to.equal('class')

var point = Point3D.new(0.3, 0.4, 0.5)

expect(point is Point).to.equal(true)
expect(point is Point3D).to.equal(true)
expect(Type.typeOf(point)).to.equal('object')

expect(point.x).to.equal(0.3)
expect(point.y).to.equal(0.4)
expect(point.z).to.equal(0.5)

func foobar(x: Class) => 'class'
func foobar(x: Point) => 'point'
func foobar(x: Point3D) => 'point3d'
func foobar(x: Number) => 'number'
func foobar(x: Object) => 'object'
func foobar(x: String) => 'string'
func foobar(x) => 'any'

expect(foobar(Point3D)).to.equal('class')
expect(foobar(point)).to.equal('point3d')
expect(foobar(point.x)).to.equal('number')
expect(foobar(point.y)).to.equal('number')
expect(foobar(point.z)).to.equal('number')
expect(foobar(0)).to.equal('number')
expect(foobar({})).to.equal('object')
expect(foobar('foo')).to.equal('string')
expect(foobar([])).to.equal('any')