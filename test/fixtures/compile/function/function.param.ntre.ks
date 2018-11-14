require expect: func

let foo = func(x: Any?) {
	return [x]
}

expect(() => foo()).to.throw()

expect(foo(1)).to.eql([1])