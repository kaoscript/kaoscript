require expect: func

func foobar(x, y) ~ Error {
    if x {
		if y {
			return 42
		}
		else {
			return null
		}
    }
    else {
        throw new Error('foobar')
    }
}

expect(try foobar(true, true)).to.equal(42)
expect(try foobar(true, false)).to.equal(null)
expect(try foobar(false, true)).to.equal(null)

expect(try foobar(true, true) ~ 0).to.equal(42)
expect(try foobar(true, false) ~ 0).to.equal(null)
expect(try foobar(false, true) ~ 0).to.equal(0)

expect(try foobar(true, true) ?? 0).to.equal(42)
expect(try foobar(true, false) ?? 0).to.equal(0)
expect(try foobar(false, true) ?? 0).to.equal(0)