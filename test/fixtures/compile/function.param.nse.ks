require expect: func, Helper, Type

func foo(x?) {
	return [x]
}

expect(foo()).to.eql([null])

expect(foo(1)).to.eql([1])