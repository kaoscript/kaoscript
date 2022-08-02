require expect: func

var dyn foo = (() => (x: String, y: String = null, z: Boolean = false, a: Number = 0) => [x, y, z, a])()

expect(() => foo()).to.throw()

expect(foo('foo')).to.eql(['foo', null, false, 0])

expect(() => foo(true)).to.throw()

expect(() => foo(42)).to.throw()

expect(foo('foo', 'bar')).to.eql(['foo', 'bar', false, 0])

expect(foo('foo', true)).to.eql(['foo', null, true, 0])

expect(foo('foo', 42)).to.eql(['foo', null, false, 42])

expect(() => foo('foo', [])).to.throw()

expect(foo('foo', 'bar', true)).to.eql(['foo', 'bar', true, 0])

expect(foo('foo', 'bar', 42)).to.eql(['foo', 'bar', false, 42])

expect(() => foo('foo', 'bar', 'qux')).to.throw()

expect(() => foo('foo', 'bar', [])).to.throw()

expect(() => foo('foo', 42, 'qux')).to.throw()

expect(() => foo('foo', true, 'qux')).to.throw()

expect(foo('foo', 'bar', true, 42)).to.eql(['foo', 'bar', true, 42])

expect(() => foo('foo', 'bar', true, 'qux')).to.throw()