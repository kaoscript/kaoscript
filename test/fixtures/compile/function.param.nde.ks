require expect: func, Helper, Type

func foo(x: any? = 42) {
	return [x]
}

expect(foo()).to.eql([42])

expect(foo(1)).to.eql([1])