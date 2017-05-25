require expect: func

let foo = func(...items: string, x = 42) {
	return [items, x]
}

expect(foo()).to.eql([[], 42])

expect(foo(1)).to.eql([[], 1])

expect(foo('foo')).to.eql([['foo'], 42])

expect(foo('foo', 2)).to.eql([['foo'], 2])

expect(foo('foo', 'bar', 'qux')).to.eql([['foo', 'bar', 'qux'], 42])

expect(foo('foo', 'bar', 'qux', 4)).to.eql([['foo', 'bar', 'qux'], 4])