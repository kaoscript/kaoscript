func foobar(functions: Array<(x: String)>) {
	for const fn in functions {
		fn('foobar')
	}
}