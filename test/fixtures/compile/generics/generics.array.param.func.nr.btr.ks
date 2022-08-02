func foobar(functions: Array<(x: String)>): Array<String> {
	return [fn('foobar') for var fn in functions]
}