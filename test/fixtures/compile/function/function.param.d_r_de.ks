require expect: func

let foo = func(x = 24, ...items, y = 42) {
	return [x, items, y]
}

expect(foo()).to.eql([24, [], 42])

expect(foo(1)).to.eql([1, [], 42])

expect(foo(1, 2)).to.eql([1, [2], 42])

expect(foo(1, 2, 3, 4)).to.eql([1, [2, 3, 4], 42])