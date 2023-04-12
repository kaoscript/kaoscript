func foobar(x) ~ Error {
    if x {
        return 42
    }
    else {
        throw Error.new('foobar')
    }
}

try foobar(true)