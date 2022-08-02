require expect: func

var dyn foo = (() => (x: String, y: String = null, z: Boolean = false, a: Number) => [x, y, z, a])()

expect(() => foo()).to.throw()

expect(() => foo('foo')).to.throw()

expect(() => foo(true)).to.throw()

expect(() => foo(42)).to.throw()

expect(foo('foo', 42)).to.eql(['foo', null, false, 42])

expect(() => foo('foo', 'bar')).to.throw()

expect(() => foo('foo', true)).to.throw()

expect(() => foo('foo', null)).to.throw()

expect(() => foo('foo', [])).to.throw()

expect(foo('foo', 'bar', 42)).to.eql(['foo', 'bar', false, 42])

expect(() => foo('foo', 'bar', true)).to.throw()

expect(() => foo('foo', 'bar', 'qux')).to.throw()

expect(() => foo('foo', 'bar', [])).to.throw()

expect(() => foo('foo', 42, 'qux')).to.throw()

expect(() => foo('foo', true, 'qux')).to.throw()

expect(foo('foo', 'bar', true, 42)).to.eql(['foo', 'bar', true, 42])

expect(() => foo('foo', 'bar', true, 'qux')).to.throw()

expect(() => foo('foo', 'bar', true, null)).to.throw()