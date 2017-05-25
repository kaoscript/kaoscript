require expect: func

let foo = func(x, ...items) {
	return [x, items]
}

expect(() => foo()).to.throw()

expect(foo(1)).to.eql([1, []])

expect(foo(1, 2)).to.eql([1, [2]])

expect(foo(1, 2, 3, 4)).to.eql([1, [2, 3, 4]])