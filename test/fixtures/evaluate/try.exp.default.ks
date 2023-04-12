require expect: func

func foobar(x) ~ Error {
    if x {
        return 42
    }
    else {
        throw Error.new('foobar')
    }
}

#[error(off)]
expect(foobar(true)).to.equal(42)

#[error(off)]
expect(() => foobar(false)).to.throw()

expect(try foobar(true)).to.equal(42)
expect(try foobar(false)).to.equal(null)
