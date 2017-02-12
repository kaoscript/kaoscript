require expect: func

func foo(x: Number = null, ...items) {
	return [x, items]
}

expect(foo()).to.eql([null, []])

expect(foo(1)).to.eql([1, []])

expect(() => foo('foo')).to.throw()

expect(foo(1, 2)).to.eql([1, [2]])

expect(() => foo('foo', 1)).to.throw()

expect(foo(null, 'foo', 1)).to.eql([null, ['foo', 1]])