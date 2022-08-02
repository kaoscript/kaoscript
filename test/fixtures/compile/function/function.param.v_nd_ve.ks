require expect: func

var dyn foo = (() => (x, y = null, z) => [x, y, z])()

expect(() => foo()).to.throw()

expect(() => foo(1)).to.throw()

expect(foo(1, 2)).to.eql([1, null, 2])

expect(foo(1, 2, 3)).to.eql([1, 2, 3])

expect(() => foo(1, 2, 3, 4)).to.throw()