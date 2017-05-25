require expect: func

let foo = func(,x) {
	return [x]
}

expect(() => foo()).to.throw()

expect(() => foo(1)).to.throw()

expect(foo(1, 2)).to.eql([2])