require expect: func

var dyn foo = func(x: Any? = 42) {
	return [x]
}

expect(foo()).to.eql([42])

expect(foo(1)).to.eql([1])