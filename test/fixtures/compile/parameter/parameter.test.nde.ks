require expect: func

var dyn foo = func(x? = null) {
	return [x]
}

expect(foo()).to.eql([null])

expect(foo(1)).to.eql([1])