require expect: func, Class, Type

func foo(x = 42) {
	return [x]
}

expect(foo()).to.eql([42])

expect(foo(1)).to.eql([1])