require expect: func

var dyn foo = (() => (_, x) => [x])()

expect(() => foo()).to.throw()

expect(() => foo(1)).to.throw()

expect(foo(1, 2)).to.eql([2])