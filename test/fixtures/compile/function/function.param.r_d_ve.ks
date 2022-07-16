require expect: func

let foo = (() => (...items, x = 42, y) => [items, x, y])()

expect(() => foo()).to.throw()

expect(foo(1)).to.eql([[], 42, 1])

expect(foo(1, 2)).to.eql([[], 1, 2])

expect(foo(1, 2, 3, 4)).to.eql([[1, 2], 3, 4])