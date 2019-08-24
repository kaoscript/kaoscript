require expect: func

let foo = (() => (x: String, y: String = null, z: Boolean = false, ...args: Number) => [x, y, z, args])()

expect(() => foo()).to.throw()

expect(foo('foo')).to.eql(['foo', null, false, []])

expect(() => foo(true)).to.throw()

expect(() => foo(42)).to.throw()

expect(foo('foo', 'bar')).to.eql(['foo', 'bar', false, []])

expect(foo('foo', true)).to.eql(['foo', null, true, []])

expect(foo('foo', 42)).to.eql(['foo', null, false, [42]])

expect(foo('foo', null)).to.eql(['foo', null, false, []])

expect(foo('foo', 42, 24, 18)).to.eql(['foo', null, false, [42, 24, 18]])

expect(() => foo('foo', [])).to.throw()

expect(foo('foo', 'bar', true)).to.eql(['foo', 'bar', true, []])

expect(foo('foo', 'bar', 42)).to.eql(['foo', 'bar', false, [42]])

expect(foo('foo', 'bar', null)).to.eql(['foo', 'bar', false, []])

expect(foo('foo', 'bar', 42, 24, 18)).to.eql(['foo', 'bar', false, [42, 24, 18]])

expect(foo('foo', null, null)).to.eql(['foo', null, false, []])

expect(() => foo('foo', 'bar', 'qux')).to.throw()

expect(() => foo('foo', 42, 'qux')).to.throw()

expect(() => foo('foo', true, 'qux')).to.throw()

expect(foo('foo', 'bar', true, 42)).to.eql(['foo', 'bar', true, [42]])

expect(foo('foo', 'bar', true, 42, 24, 18)).to.eql(['foo', 'bar', true, [42, 24, 18]])

expect(foo('foo', null, null, 42, 24, 18)).to.eql(['foo', null, false, [42, 24, 18]])