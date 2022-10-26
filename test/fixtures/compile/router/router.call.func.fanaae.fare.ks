func foobar(fn: (a?, b, c)) {
	return fn(0, 1, 2)
}

foobar((a, ...) => {
	if ?a {
	}
})