require expect: func

func foo(x: any?) {
	return [x]
}

expect(foo()).to.eql([null])

expect(foo(1)).to.eql([1])