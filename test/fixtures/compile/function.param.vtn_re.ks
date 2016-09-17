require expect: func, Helper, Type

func foo(x: Number?, ...items) {
	return [x, items]
}

expect(foo()).to.eql([null, []])

expect(foo(1)).to.eql([1, []])

expect(foo('foo')).to.eql([null, ['foo']])

expect(foo(1, 2)).to.eql([1, [2]])

expect(foo('foo', 1)).to.eql([null, ['foo', 1]])