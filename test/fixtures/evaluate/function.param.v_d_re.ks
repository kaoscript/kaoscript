require expect: func

let foo = (() => (x, y = 42, ...items) => [x, y, items])()

expect(() => foo()).to.throw()

expect(foo(1)).to.eql([1, 42, []])

expect(foo(1, 2)).to.eql([1, 2, []])

expect(foo(1, 2, 3, 4)).to.eql([1, 2, [3, 4]])