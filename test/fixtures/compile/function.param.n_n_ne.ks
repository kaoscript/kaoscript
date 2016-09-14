require expect: func, Class, Type

func foo(x?, y?, z?) {
	return [x, y, z]
}

expect(foo()).to.eql([null, null, null])

expect(foo(1)).to.eql([1, null, null])

expect(foo(1, 2)).to.eql([1, 2, null])

expect(foo(1, 2, 3)).to.eql([1, 2, 3])