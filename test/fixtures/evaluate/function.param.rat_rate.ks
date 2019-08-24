require expect: func

let foo = (() => (...{1,3}items: Number, ...{1,3}values: String) => [items, values])()

expect(() => foo()).to.throw()

expect(() => foo(1)).to.throw()

expect(() => foo(1, 2)).to.throw()

expect(foo(1, 'foo')).to.eql([[1], ['foo']])

expect(foo(1, 2, 3, 'foo')).to.eql([[1, 2, 3], ['foo']])

expect(foo(1, 'foo', 'bar', 'qux')).to.eql([[1], ['foo', 'bar', 'qux']])

expect(foo(1, 2, 3, 'foo', 'bar', 'qux')).to.eql([[1, 2, 3], ['foo', 'bar', 'qux']])

expect(() => foo(1, 2, 3, 4, 'foo')).to.throw()