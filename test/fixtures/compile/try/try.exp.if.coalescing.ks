func test(x): Boolean ~ Error {
    if x {
        return true
    }
    else {
        throw new Error('foobar')
    }
}

if try test(true) ~ false {
}
else {
}