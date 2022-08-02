require expect: func

var dyn foo = (() => (x: Number = null) => [x])()

expect(foo()).to.eql([null])

expect(foo(1)).to.eql([1])

expect(() => foo('foo')).to.throw()

expect(() => foo(1, 2)).to.throw()

expect(() => foo('foo', 1)).to.throw()