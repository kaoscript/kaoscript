require expect: func, Class, Type

func foo(u?, v?, x, y?, z?) {
	return [u, v, x, y, z]
}

expect(() => foo()).to.throw()

expect(foo(1)).to.eql([null, null, 1, null, null])

expect(foo(1, 2)).to.eql([1, null, 2, null, null])

expect(foo(1, 2, 3)).to.eql([1, 2, 3, null, null])

expect(foo(1, 2, 3, 4)).to.eql([1, 2, 3, 4, null])

expect(foo(1, 2, 3, 4, 5)).to.eql([1, 2, 3, 4, 5])