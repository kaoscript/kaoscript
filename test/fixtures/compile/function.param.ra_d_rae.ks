require expect: func, Helper, Type

func foo(...{1,3}items, x = 42, ...{1,3}values) {
	return [items, x, values]
}

expect(() => foo()).to.throw()

expect(() => foo(1)).to.throw()

expect(foo(1, 2)).to.eql([[1], 42, [2]])

expect(foo(1, 2, 3)).to.eql([[1, 2], 42, [3]])

expect(foo(1, 2, 3, 4)).to.eql([[1, 2, 3], 42, [4]])

expect(foo(1, 2, 3, 4, 5)).to.eql([[1, 2, 3], 4, [5]])

expect(foo(1, 2, 3, 4, 5, 6)).to.eql([[1, 2, 3], 4, [5, 6]])

expect(foo(1, 2, 3, 4, 5, 6, 7)).to.eql([[1, 2, 3], 4, [5, 6, 7]])