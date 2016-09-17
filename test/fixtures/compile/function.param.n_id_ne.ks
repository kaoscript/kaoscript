require expect: func, Helper, Type

func foo(x?, :any?, z?) {
	return [x, z]
}

expect(foo()).to.eql([null, null])

expect(foo(1)).to.eql([1, null])

expect(foo(1, 2)).to.eql([1, null])

expect(foo(1, 2, 3)).to.eql([1, 3])