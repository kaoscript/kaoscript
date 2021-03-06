require expect: func

let foo = (() => (x) => [x])()

expect(() => foo()).to.throw()

expect(foo(1)).to.eql([1])

expect(() => foo(null)).to.throw()

expect(foo(1, 2)).to.eql([1])