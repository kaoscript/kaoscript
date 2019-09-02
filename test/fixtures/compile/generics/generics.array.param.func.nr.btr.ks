func foobar(functions: Array<(x: String)>): Array<String> {
	return [fn('foobar') for const fn in functions]
}