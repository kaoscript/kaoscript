require expect: func

var dyn foo = (() => ({ x }) => [x])()

struct StructA {
	x: Number
	y: Number
}

expect(foo(StructA.new(0, 0))).to.eql([0])

expect(foo({x: 0, y: 0})).to.eql([0])

class ClassA {
	public {
		x: Number
		y: Number
	}
	constructor(@x, @y)
}

expect(foo(ClassA.new(0, 0))).to.eql([0])