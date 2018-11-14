require expect: func

let foo = func(...items, x, y, z) {
	return [items, x, y, z]
}

expect(() => foo()).to.throw()

expect(() => foo(1)).to.throw()

expect(() => foo(1, 2)).to.throw()

expect(foo(1, 2, 3)).to.eql([[], 1, 2, 3])

expect(foo(1, 2, 3, 4)).to.eql([[1], 2, 3, 4])

expect(foo(1, 2, 3, 4, 5, 6)).to.eql([[1, 2, 3], 4, 5, 6])