require expect: func

let foo = (() => (...items: string, x = 42) => [items, x])()

expect(foo()).to.eql([[], 42])

expect(foo(1)).to.eql([[], 1])

expect(foo(true)).to.eql([[], true])

expect(foo(null)).to.eql([[], 42])

expect(foo('foo')).to.eql([[], 'foo'])

expect(foo('foo', 2)).to.eql([['foo'], 2])

expect(foo('foo', true)).to.eql([['foo'], true])

expect(foo('foo', null)).to.eql([['foo'], 42])

expect(foo('foo', 'bar', 'qux')).to.eql([['foo', 'bar'], 'qux'])

expect(foo('foo', 'bar', 'qux', 4)).to.eql([['foo', 'bar', 'qux'], 4])