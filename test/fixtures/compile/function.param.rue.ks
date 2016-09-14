require expect: func, Class, Type

func foo(...{1,}items) {
	return [items]
}

expect(() => foo()).to.throw()

expect(foo(1)).to.eql([[1]])

expect(foo(1, 2)).to.eql([[1, 2]])

expect(foo(1, 2, 3)).to.eql([[1, 2, 3]])

expect(foo(1, 2, 3, 4)).to.eql([[1, 2, 3, 4]])