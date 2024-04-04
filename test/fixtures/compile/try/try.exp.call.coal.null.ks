require expect: func

func foobar(x) ~ Error {
    if x {
        return 42
    }
    else {
        throw Error.new('foobar')
    }
}

expect(try foobar(true) ?? 24)