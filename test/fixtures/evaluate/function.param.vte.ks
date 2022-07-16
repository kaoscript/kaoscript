require expect: func

let foo = (() => (x: Number) => [x])()

expect(() => foo()).to.throw()

expect(foo(1)).to.eql([1])

expect(() => foo('foo')).to.throw()

expect(() => foo(1, 2)).to.throw()

expect(() => foo('foo', 1)).to.throw()