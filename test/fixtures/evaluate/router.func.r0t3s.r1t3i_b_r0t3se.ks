require expect: func

func foobar(...{0,3}args: String) {
	return 0
}
func foobar(...{1,3}values: Number, flag: Boolean, ...{0,3}args: String) {
	return 1
}

func f(...args) => foobar(...args)

expect(f()).to.eql(0)

expect(() => f(true)).to.throw()

expect(() => f(1)).to.throw()

expect(f('a')).to.eql(0)

expect(() => f(1, 2)).to.throw()

expect(f(1, true)).to.eql(1)

expect(f('a', 'b')).to.eql(0)