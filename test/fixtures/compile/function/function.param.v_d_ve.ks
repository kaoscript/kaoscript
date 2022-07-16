require expect: func

let foo = (() => (x, y = 42, z) => [x, y, z])()

expect(() => foo()).to.throw()

expect(() => foo(1)).to.throw()

expect(foo(1, 2)).to.eql([1, 42, 2])

expect(() => foo(1, 2, 3, 4)).to.throw()