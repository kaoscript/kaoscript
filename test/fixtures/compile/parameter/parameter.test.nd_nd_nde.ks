require expect: func

var dyn foo = func(x? = null, y? = null, z? = null) {
	return [x, y, z]
}

expect(foo()).to.eql([null, null, null])

expect(foo(1)).to.eql([1, null, null])

expect(foo(1, 2)).to.eql([1, 2, null])

expect(foo(1, 2, 3)).to.eql([1, 2, 3])