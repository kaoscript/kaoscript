func foobar(functions: Array<(x: String)>) {
	for var fn in functions {
		fn('foobar')
	}
}