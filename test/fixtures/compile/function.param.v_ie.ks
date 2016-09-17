require expect: func, Helper, Type

func foo(x,) {
	return [x]
}

expect(() => foo()).to.throw()

expect(foo(1)).to.eql([1])

expect(foo(1, 2)).to.eql([1])