require expect: func

type int = Number

func foo(x: int?, y: string) {
	return [x, y]
}

expect(() => foo()).to.throw()

expect(() => foo(1)).to.throw()

expect(foo('foo')).to.eql([null, 'foo'])

expect(foo(1, 'foo')).to.eql([1, 'foo'])

expect(() => foo('foo', 'bar')).to.throw()