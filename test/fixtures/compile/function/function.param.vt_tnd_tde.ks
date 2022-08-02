require expect: func

var dyn foo = (() => (x: String, y: String = null, z: Boolean = false) => [x, y, z])()

expect(() => foo()).to.throw()

expect(foo('foo')).to.eql(['foo', null, false])

expect(() => foo(true)).to.throw()

expect(() => foo(42)).to.throw()

expect(foo('foo', 'bar')).to.eql(['foo', 'bar', false])

expect(foo('foo', true)).to.eql(['foo', null, true])

expect(() => foo('foo', 42)).to.throw()

expect(foo('foo', 'bar', true)).to.eql(['foo', 'bar', true])

expect(() => foo('foo', 'bar', 'qux')).to.throw()

expect(() => foo('foo', 'bar', 42)).to.throw()

expect(() => foo('foo', 42, 'qux')).to.throw()

expect(() => foo('foo', true, 'qux')).to.throw()