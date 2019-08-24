require expect: func

let foo = (() => (x!? = 42) => [x])()

expect(() => foo()).to.throw()

expect(foo(null)).to.eql([null])

expect(foo(1)).to.eql([1])