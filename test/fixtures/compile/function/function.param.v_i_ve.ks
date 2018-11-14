require expect: func

let foo = func(x,, y) {
	return [x, y]
}

expect(() => foo()).to.throw()

expect(() => foo(1)).to.throw()

expect(() => foo(1, 2)).to.throw()

expect(foo(1, 2, 3)).to.eql([1, 3])

expect(foo(1, null, 3)).to.eql([1, 3])