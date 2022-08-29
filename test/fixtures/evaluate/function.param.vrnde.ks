require expect: func

var dyn foo = (() => (x!? = null) => [x])()

expect(() => foo()).to.throw()

expect(foo(null)).to.eql([null])

expect(foo(1)).to.eql([1])