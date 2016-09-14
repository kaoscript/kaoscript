require expect: func, Class, Type

func foo(x?, y?, z) {
	return [x, y, z]
}

expect(() => foo()).to.throw()

expect(foo(1)).to.eql([null, null, 1])

expect(foo(1, 2)).to.eql([1, null, 2])

expect(foo(1, 2, 3)).to.eql([1, 2, 3])