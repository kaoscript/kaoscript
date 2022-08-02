require expect: func

var dyn foo = (() => (...items, ...{1,3}values: Number) => [items, values])()

expect(() => foo()).to.throw()

expect(foo(1)).to.eql([[], [1]])

expect(foo(1, 2)).to.eql([[], [1, 2]])

expect(foo(1, 2, 3)).to.eql([[], [1, 2, 3]])

expect(foo(1, 2, 3, 4)).to.eql([[1], [2, 3, 4]])

expect(foo(1, 2, 3, 4, 5)).to.eql([[1, 2], [3, 4, 5]])

expect(foo(1, 2, 3, 4, 5, 6)).to.eql([[1, 2, 3], [4, 5, 6]])

expect(foo(1, 2, 3, 4, 5, 6, 7)).to.eql([[1, 2, 3, 4], [5, 6, 7]])