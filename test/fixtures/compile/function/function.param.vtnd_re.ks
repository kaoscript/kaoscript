require expect: func

var dyn foo = (() => (x: Number = null, ...items) => [x, items])()

expect(foo()).to.eql([null, []])

expect(foo(1)).to.eql([1, []])

expect(foo('foo')).to.eql([null, ['foo']])

expect(foo(1, 2)).to.eql([1, [2]])

expect(foo('foo', 1)).to.eql([null, ['foo', 1]])

expect(foo(null, 'foo', 1)).to.eql([null, ['foo', 1]])