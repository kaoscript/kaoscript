require expect: func

var dyn foo = (() => (...items: string) => [items])()

expect(foo()).to.eql([[]])

expect(() => foo(1)).to.throw()

expect(() => foo(null)).to.throw()

expect(() => foo(true)).to.throw()

expect(foo('foo')).to.eql([['foo']])

expect(() => foo('true', 1)).to.throw()

expect(() => foo('true', true)).to.throw()

expect(() => foo('true', null)).to.throw()

expect(foo('foo', 'bar', 'qux')).to.eql([['foo', 'bar', 'qux']])

expect(() => foo('foo', 'bar', 'qux', 4)).to.throw()