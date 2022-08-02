require expect: func

var dyn foo = (() => (...{1,3}items: Number, ...values) => [items, values])()

expect(() => foo()).to.throw()

expect(foo(1)).to.eql([[1], []])

expect(() => foo('foo')).to.throw()

expect(foo(1, 2)).to.eql([[1, 2], []])

expect(foo(1, 'foo')).to.eql([[1], ['foo']])

expect(foo(1, 2, 3)).to.eql([[1, 2, 3], []])

expect(foo(1, 2, 3, 4)).to.eql([[1, 2, 3], [4]])

expect(foo(1, 2, 3, 4, 5)).to.eql([[1, 2, 3], [4, 5]])

expect(foo(1, 2, 3, 4, 5, 6)).to.eql([[1, 2, 3], [4, 5, 6]])

expect(foo(1, 2, 3, 4, 5, 6, 7)).to.eql([[1, 2, 3], [4, 5, 6, 7]])