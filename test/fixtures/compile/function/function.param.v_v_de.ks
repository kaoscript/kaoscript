require expect: func

let foo = func(x, y, z = 24) {
	return [x, y, z]
}

expect(() => foo()).to.throw()

expect(() => foo(1)).to.throw()

expect(foo(1, 2)).to.eql([1, 2, 24])

expect(foo(1, 2, 3, 4)).to.eql([1, 2, 3])