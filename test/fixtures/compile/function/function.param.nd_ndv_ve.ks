require expect: func

let foo = func(x = null, y? = 42, z) {
	return [x, y, z]
}

expect(() => foo()).to.throw()

expect(foo(1)).to.eql([null, 42, 1])

expect(foo(1, 2)).to.eql([1, 42, 2])

expect(foo(1, 2, 3)).to.eql([1, 2, 3])