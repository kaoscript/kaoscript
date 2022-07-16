require expect: func

let foo = (() => (x, y = 42, z = 24) => [x, y, z])()

expect(() => foo()).to.throw()

expect(foo(1)).to.eql([1, 42, 24])

expect(foo(1, 2)).to.eql([1, 2, 24])

expect(() => foo(1, 2, 3, 4)).to.throw()