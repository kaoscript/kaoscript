require expect: func

var dyn foo = (() => (x?) => [x])()

expect(() => foo()).to.throw()

expect(foo(1)).to.eql([1])