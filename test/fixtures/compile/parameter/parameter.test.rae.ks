require expect: func

var dyn foo = (() => (...{,3}items) => [items])()

expect(foo()).to.eql([[]])

expect(foo(1)).to.eql([[1]])

expect(foo(1, 2)).to.eql([[1, 2]])

expect(foo(1, 2, 3)).to.eql([[1, 2, 3]])

expect(() => foo(1, 2, 3, 4)).to.throw()