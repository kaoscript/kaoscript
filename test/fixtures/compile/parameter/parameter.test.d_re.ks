require expect: func

var dyn foo = func(x = 42, ...items) {
	return [x, items]
}

expect(foo(42)).to.eql([42, []])

expect(foo(1)).to.eql([1, []])

expect(foo(1, 2)).to.eql([1, [2]])

expect(foo(1, 2, 3, 4)).to.eql([1, [2, 3, 4]])