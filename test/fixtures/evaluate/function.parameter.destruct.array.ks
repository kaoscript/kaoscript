require expect: func

let foo = (() => ([ x ]) => [x])()

tuple TupleA {
	x: Number
	y: Number
}

expect(foo(TupleA(0, 0))).to.eql([0])

expect(foo([0, 0])).to.eql([0])