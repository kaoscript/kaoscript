require expect: func

let foo = (() => (x: String, y!: String = 'foobar') => [x, y])()

expect(() => foo()).to.throw()

expect(() => foo('foo')).to.throw()

expect(() => foo(true)).to.throw()

expect(() => foo(42)).to.throw()

expect(foo('foo', 'bar')).to.eql(['foo', 'bar'])

expect(foo('foo', null)).to.eql(['foo', 'foobar'])

expect(() => foo('foo', true)).to.throw()