require expect: func, Class, Type

func foo(x, ...items, y) {
	return [x, items, y]
}

expect(() => foo()).to.throw()

expect(() => foo(1)).to.throw()

expect(foo(1, 2)).to.eql([1, [], 2])

expect(foo(1, 2, 3)).to.eql([1, [2], 3])

expect(foo(1, 2, 3, 4)).to.eql([1, [2, 3], 4])