require expect: func

var dyn foo = (() => (x, y, z) => [x, y, z])()

expect(() => foo()).to.throw()

expect(() => foo(1)).to.throw()

expect(() => foo(1, 2)).to.throw()

expect(foo(1, 2, 3)).to.eql([1, 2, 3])