require expect: func

var dyn foo = (() => (x: String, y: String? = null, z! = false) => [x, y, z])()

expect(() => foo()).to.throw()

expect(() => foo('foo')).to.throw()

expect(() => foo(true)).to.throw()

expect(() => foo(42)).to.throw()

expect(foo('foo', true)).to.eql(['foo', null, true])

expect(foo('foo', 42)).to.eql(['foo', null, 42])

expect(foo('foo', 'bar')).to.eql(['foo', null, 'bar'])

expect(foo('foo', null)).to.eql(['foo', null, false])

expect(foo('foo', 'bar', true)).to.eql(['foo', 'bar', true])

expect(foo('foo', 'bar', 'qux')).to.eql(['foo', 'bar', 'qux'])

expect(foo('foo', 'bar', 42)).to.eql(['foo', 'bar', 42])

expect(foo('foo', 'bar', null)).to.eql(['foo', 'bar', false])