require expect: func, Helper, Type

func foo(u?, v, x?, y, z?) {
	return [u, v, x, y, z]
}

expect(() => foo()).to.throw()

expect(() => foo(1)).to.throw()

expect(foo(1, 2)).to.eql([null, 1, null, 2, null])

expect(foo(1, 2, 3)).to.eql([1, 2, null, 3, null])

expect(foo(1, 2, 3, 4)).to.eql([1, 2, 3, 4, null])

expect(foo(1, 2, 3, 4, 5)).to.eql([1, 2, 3, 4, 5])