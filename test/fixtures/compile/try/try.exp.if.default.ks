func foobar(x) ~ Error {
    if x {
        return 42
    }
    else {
        throw new Error('foobar')
    }
}

if try foobar(true) {
}
else {
}