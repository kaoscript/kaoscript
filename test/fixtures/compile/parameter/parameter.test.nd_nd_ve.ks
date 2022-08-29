require expect: func

var dyn foo = (() => (x? = null, y? = null, z) => [x, y, z])()

expect(() => foo()).to.throw()

expect(foo(1)).to.eql([null, null, 1])

expect(foo(1, 2)).to.eql([1, null, 2])

expect(foo(1, 2, 3)).to.eql([1, 2, 3])