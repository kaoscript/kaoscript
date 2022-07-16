require expect: func

let foo = func(...items, x = 42) {
	return [items, x]
}

expect(foo()).to.eql([[], 42])

expect(foo(1)).to.eql([[], 1])

expect(foo(1, 2)).to.eql([[1], 2])

expect(foo(1, 2, 3, 4)).to.eql([[1, 2, 3], 4])