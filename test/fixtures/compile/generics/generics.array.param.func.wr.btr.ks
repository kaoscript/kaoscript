func foobar(functions: Array<(x: String): Number>): Array<String> {
	return [fn('foobar') for const fn in functions]
}