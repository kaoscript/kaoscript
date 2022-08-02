require expect: func

var dyn foo = (() => (x: Any?) => [x])()

expect(() => foo()).to.throw()

expect(foo(1)).to.eql([1])