require expect: func

func foobar(...{0,3}args: String) {
	return 0
}
func foobar(...{1,3}values: Number, flag: Number, ...{0,3}args: String) {
	return 1
}

func f(...args) => foobar(...args)

expect(f()).to.eql(0)

expect(f('')).to.eql(0)

expect(f(1, 2)).to.eql(1)