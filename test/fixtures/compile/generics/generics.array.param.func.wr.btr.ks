func foobar(functions: Array<(x: String): Number>): Array<String> {
	return [fn('foobar') for var fn in functions]
}