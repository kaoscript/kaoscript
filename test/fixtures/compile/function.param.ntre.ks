require expect: func

func foo(x: Any?) {
	return [x]
}

expect(() => foo()).to.throw()

expect(foo(1)).to.eql([1])