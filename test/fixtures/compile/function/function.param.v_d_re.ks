require expect: func

let foo = func(x, y = 42, ...items) {
	return [x, y, items]
}

expect(() => foo()).to.throw()

expect(foo(1)).to.eql([1, 42, []])

expect(foo(1, 2)).to.eql([1, 2, []])

expect(foo(1, 2, 3, 4)).to.eql([1, 2, [3, 4]])