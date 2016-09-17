require expect: func, Helper, Type

func foo(x, ...items, y = 42) {
	return [x, items, y]
}

expect(() => foo()).to.throw()

expect(foo(1)).to.eql([1, [], 42])

expect(foo(1, 2)).to.eql([1, [2], 42])

expect(foo(1, 2, 3, 4)).to.eql([1, [2, 3, 4], 42])