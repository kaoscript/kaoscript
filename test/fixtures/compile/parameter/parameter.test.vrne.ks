require expect: func

var dyn foo = (() => (x?) => [x])()

expect(() => foo()).to.throw()

expect(foo(1)).to.eql([1])

expect(foo(null)).to.eql([null])

expect(() => foo(1, 2)).to.throw()