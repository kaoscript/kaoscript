require expect: func

func foo(x = null,, z = null) {
	return [x, z]
}

expect(() => foo()).to.throw()

expect(foo(1)).to.eql([null, null])

expect(foo(1, 2)).to.eql([1, null])

expect(foo(1, 2, 3)).to.eql([1, 3])