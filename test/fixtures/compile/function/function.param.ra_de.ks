require expect: func

var dyn foo = (() => (...{1,3}items, x = 42) => [items, x])()

expect(() => foo()).to.throw()

expect(foo(1)).to.eql([[1], 42])

expect(foo(1, 2)).to.eql([[1, 2], 42])

expect(foo(1, 2, 3)).to.eql([[1, 2, 3], 42])

expect(foo(1, 2, 3, 4)).to.eql([[1, 2, 3], 4])