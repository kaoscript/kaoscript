require expect: func

var dyn foo = (() => (x!: Any? = 42) => [x])()

expect(() => foo()).to.throw()

expect(foo(null)).to.eql([null])

expect(foo(1)).to.eql([1])