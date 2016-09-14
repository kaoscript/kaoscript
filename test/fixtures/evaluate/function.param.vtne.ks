require expect: func

type int = Number

func foo(x: int?) {
	return [x]
}

expect(foo()).to.eql([null])

expect(foo(1)).to.eql([1])

expect(() => foo('foo')).to.throw()

expect(foo(1, 2)).to.eql([1])

expect(() => foo('foo', 1)).to.throw()