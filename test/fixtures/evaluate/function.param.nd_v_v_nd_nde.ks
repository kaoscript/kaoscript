require expect: func

var dyn foo = (() => (u = null, v, x, y = null, z = null) => [u, v, x, y, z])()

expect(() => foo()).to.throw()

expect(() => foo(1)).to.throw()

expect(foo(1, 2)).to.eql([null, 1, 2, null, null])

expect(foo(1, 2, 3)).to.eql([1, 2, 3, null, null])

expect(foo(1, 2, 3, 4)).to.eql([1, 2, 3, 4, null])

expect(foo(1, 2, 3, 4, 5)).to.eql([1, 2, 3, 4, 5])