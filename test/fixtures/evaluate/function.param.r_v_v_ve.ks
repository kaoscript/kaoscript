require expect: func

var dyn foo = (() => (...items, x, y, z) => [items, x, y, z])()

expect(() => foo()).to.throw()

expect(() => foo(1)).to.throw()

expect(() => foo(1, 2)).to.throw()

expect(foo(1, 2, 3)).to.eql([[], 1, 2, 3])

expect(foo(1, 2, 3, 4)).to.eql([[1], 2, 3, 4])

expect(foo(1, 2, 3, 4, 5, 6)).to.eql([[1, 2, 3], 4, 5, 6])