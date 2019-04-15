require expect: func

let foo = (() => (x, ...items, y = 42) => [x, items, y])()

expect(() => foo()).to.throw()

expect(foo(1)).to.eql([1, [], 42])

expect(foo(1, 2)).to.eql([1, [2], 42])

expect(foo(1, 2, 3, 4)).to.eql([1, [2, 3, 4], 42])