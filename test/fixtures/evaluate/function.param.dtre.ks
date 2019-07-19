require expect: func

let foo = (() => (x!: Number = 42) => [x])()

expect(() => foo()).to.throw()

expect(foo(null)).to.eql([42])

expect(foo(1)).to.eql([1])

expect(() => foo('foobar')).to.throw()