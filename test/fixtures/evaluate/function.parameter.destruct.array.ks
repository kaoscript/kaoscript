require expect: func

var dyn foo = (() => ([ x ]) => [x])()

tuple TupleA [
	x: Number
	y: Number
]

expect(foo(TupleA.new(0, 0))).to.eql([0])

expect(foo([0, 0])).to.eql([0])