require expect: func

func foobar(x) ~ Error {
    if x {
        return 42
    }
    else {
        throw Error.new('foobar')
    }
}

expect(try foobar(true)).to.equal(42)
expect(try foobar(false)).to.equal(null)

expect(try! foobar(true)).to.equal(42)
expect(() => try! foobar(false)).to.throw()
