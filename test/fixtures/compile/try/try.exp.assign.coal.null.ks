func foobar(x) ~ Error {
    if x {
        return 42
    }
    else {
        throw Error.new('foobar')
    }
}

var dyn x = try foobar(true) ?? 24