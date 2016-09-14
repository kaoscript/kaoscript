require expect: func, Class, Type

func foo(...items, x = 42, y) {
	return [items, x, y]
}

expect(() => foo()).to.throw()

expect(foo(1)).to.eql([[], 42, 1])

expect(foo(1, 2)).to.eql([[1], 42, 2])

expect(foo(1, 2, 3, 4)).to.eql([[1, 2, 3], 42, 4])