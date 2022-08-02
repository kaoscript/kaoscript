func foobar(x) ~ Error {
    if x {
        return 42
    }
    else {
        throw new Error('foobar')
    }
}

var dyn x = try! foobar(true)