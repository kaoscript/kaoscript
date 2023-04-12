func test(x): Boolean ~ Error {
    if x {
        return true
    }
    else {
        throw Error.new('foobar')
    }
}

if try test(true) ~ false {
}
else {
}